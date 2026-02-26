-- 03_schema_tasks.sql
-- MySQL specific tasks


CREATE TABLE esemenyek (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  starts_at DATETIME NOT NULL,
  location VARCHAR(200),
  capacity INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_esemenyek_starts (starts_at)

) ENGINE=InnoDB;



CREATE TABLE tranzakciok (

  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  status ENUM(
    'sikeres',
    'sikertelen',
    'folyamatban'
  ) NOT NULL,

  total_gross DECIMAL(12,2) NOT NULL,

  created_at DATETIME NOT NULL,

  INDEX idx_tranz_date (created_at),
  INDEX idx_tranz_status (status)

) ENGINE=InnoDB;



CREATE TABLE jegyek (

  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  esemeny_id BIGINT UNSIGNED NOT NULL,

  status ENUM(
    'eladott',
    'szabad',
    'foglalt',
    'nem_eladhato'
  ) NOT NULL DEFAULT 'szabad',

  price_gross DECIMAL(10,2) NOT NULL,

  transaction_id BIGINT UNSIGNED,

  CONSTRAINT fk_jegyek_event
    FOREIGN KEY (esemeny_id)
    REFERENCES esemenyek(id)
    ON DELETE CASCADE,

  INDEX idx_jegyek_event (esemeny_id),
  INDEX idx_jegyek_status (status)

) ENGINE=InnoDB;



CREATE TABLE tranzakcio_elemek (

  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  tranzakcio_id BIGINT UNSIGNED NOT NULL,

  jegy_id BIGINT UNSIGNED,

  qty INT NOT NULL,

  unit_gross DECIMAL(10,2),

  line_gross DECIMAL(12,2),

  CONSTRAINT fk_elem_tranz
    FOREIGN KEY (tranzakcio_id)
    REFERENCES tranzakciok(id)
    ON DELETE CASCADE,

  INDEX idx_elem_tranz (tranzakcio_id)

) ENGINE=InnoDB;



CREATE TABLE tranzakcio_fizetesi_modok (

 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

 tranzakcio_id BIGINT UNSIGNED NOT NULL,

 payment_method ENUM(
   'bankkartya',
   'keszpenz',
   'szepkartya',
   'ajandekutalvany'
 ) NOT NULL,

 amount_gross DECIMAL(12,2),

 CONSTRAINT fk_pay_tranz
   FOREIGN KEY (tranzakcio_id)
   REFERENCES tranzakciok(id)
   ON DELETE CASCADE,

 INDEX idx_pay_method (payment_method)

) ENGINE=InnoDB;
