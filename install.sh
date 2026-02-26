cat > install.sh << 'EOF'
#!/usr/bin/env sh
set -eu

# -----------------------------
# Install & run script for CI4 project (WSL/Linux)
# Supports: Ubuntu/Debian (apt), Alpine (apk)
# -----------------------------

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_NAME="${DB_NAME:-ci_admin_test}"
DB_USER="${DB_USER:-ciuser}"
DB_PASS="${DB_PASS:-cipass}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8080}"

cd "$PROJECT_DIR"

# Detect OS
OS_ID=""
if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  OS_ID="${ID:-}"
fi

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_as_root() {
  # If running as root, execute directly. Otherwise try sudo.
  if [ "$(id -u)" -eq 0 ]; then
    sh -c "$1"
    return
  fi

  if need_cmd sudo; then
    sudo sh -c "$1"
    return
  fi

  echo "ERROR: Need root privileges but sudo is not available."
  echo "Run this script as root, or install sudo / use Ubuntu WSL."
  exit 1
}

install_packages_apt() {
  echo "Installing packages via apt..."
  run_as_root "apt update"
  run_as_root "apt install -y git curl unzip zip php php-cli php-mbstring php-intl php-mysql php-xml php-curl php-zip mariadb-server mariadb-client composer"
}

install_packages_apk() {
  echo "Installing packages via apk..."
  run_as_root "apk update"
  # Alpine package names can vary slightly by version; these are common
  run_as_root "apk add --no-cache git curl unzip zip php php-cli php-mbstring php-intl php-mysqli php-xml php-curl php-zip mariadb mariadb-client composer"
}

start_mariadb() {
  # Ubuntu/Debian service
  if need_cmd service; then
    if service mariadb status >/dev/null 2>&1; then
      run_as_root "service mariadb start || true"
      return
    fi
    if service mysql status >/dev/null 2>&1; then
      run_as_root "service mysql start || true"
      return
    fi
  fi

  # Alpine OpenRC (some WSL images)
  if need_cmd rc-service; then
    run_as_root "rc-service mariadb start || true"
    return
  fi

  echo "WARN: Could not detect service manager. MariaDB might already be running."
}

init_mariadb_alpine_if_needed() {
  # Alpine sometimes needs initial DB setup
  if [ "$OS_ID" = "alpine" ]; then
    if [ ! -d /var/lib/mysql/mysql ]; then
      echo "Initializing MariaDB (Alpine)..."
      run_as_root "mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld"
      run_as_root "mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null 2>&1 || true"
    fi
  fi
}

create_env_if_missing() {
  if [ ! -f .env ]; then
    echo "Creating .env from env template..."
    cp env .env
  fi

  # Ensure key settings exist (append if missing)
  if ! grep -q "^CI_ENVIRONMENT" .env; then
    printf "\nCI_ENVIRONMENT = development\n" >> .env
  fi

  # Append DB settings if not present
  if ! grep -q "^database.default.database" .env; then
    cat >> .env <<EOT

app.baseURL = 'http://localhost:${PORT}/'

database.default.hostname = localhost
database.default.database = ${DB_NAME}
database.default.username = ${DB_USER}
database.default.password = ${DB_PASS}
database.default.DBDriver = MySQLi
database.default.port = 3306
EOT
  fi
}

composer_install() {
  if need_cmd composer; then
    echo "Running composer install..."
    composer install --no-interaction
  else
    echo "ERROR: composer not found."
    exit 1
  fi
}

db_setup() {
  echo "Setting up database and user..."

  # Create DB and user using root socket auth (best effort)
  # Works on most MariaDB installs where root uses unix_socket plugin.
  if need_cmd mariadb; then
    run_as_root "mariadb -e \"CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4;\""
    run_as_root "mariadb -e \"CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';\""
    run_as_root "mariadb -e \"ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';\""
    run_as_root "mariadb -e \"GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;\""
  else
    # fallback to mysql command name
    run_as_root "mysql -e \"CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4;\""
    run_as_root "mysql -e \"CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';\""
    run_as_root "mysql -e \"ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';\""
    run_as_root "mysql -e \"GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;\""
  fi
}

import_sql() {
  echo "Importing SQL schemas and dummy data..."

  mysql -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < database/01_schema_admin.sql
  mysql -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < database/02_seed_admin.sql
  mysql -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < database/03_schema_tasks.sql
  mysql -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < database/04_dummy_tasks.sql
}

seed_admin() {
  echo "Seeding admin user..."
  php spark seed:admin || true
}

run_server() {
  echo ""
  echo "✅ Setup complete."
  echo "Open: http://localhost:${PORT}/login"
  echo "Login: admin / admin1234"
  echo ""
  echo "Starting server..."
  php spark serve --host "${HOST}" --port "${PORT}"
}

main() {
  echo "Detected OS: ${OS_ID:-unknown}"

  if [ "$OS_ID" = "alpine" ]; then
    install_packages_apk
    init_mariadb_alpine_if_needed
  else
    # default to apt-based distros
    install_packages_apt
  fi

  start_mariadb
  create_env_if_missing
  composer_install
  db_setup
  import_sql
  seed_admin
  run_server
}

main
EOF

chmod +x install.sh
