# Jegyx1 próbafeladat – CodeIgniter 4 admin alkalmazás

Ez a projekt a Jegyx1 próbafeladat megoldása.

A rendszer egy egyszerű admin alkalmazás CodeIgniter 4 keretrendszerben, Vue.js frontenddel.

Tartalmaz:
- Bejelentkezési felület validációval
- Growl (toast) üzenetek sikeres/hibás login esetén
- Session alapú authentikáció
- Hierarchikus (többszintű) menürendszer
- Rekurzív menü felépítés
- MySQL feladatok (táblák + lekérdezések)


--------------------------------------------------

Követelmények

- PHP 8.1+
- Composer
- MySQL vagy MariaDB


--------------------------------------------------

Telepítés


1. Függőségek telepítése

composer install


--------------------------------------------------

2. Környezet beállítása

.env fájl létrehozása:

cp env .env


.env fájl módosítása:

CI_ENVIRONMENT = development

app.baseURL = 'http://localhost:8080/'

database.default.hostname = localhost

database.default.database = ci_admin_test

database.default.username = ciuser

database.default.password = cipass

database.default.DBDriver = MySQLi

database.default.port = 3306


--------------------------------------------------

3. Adatbázis létrehozása

CREATE DATABASE ci_admin_test CHARACTER SET utf8mb4;


--------------------------------------------------

4. Adatbázis import

mysql -u ciuser -pcipass ci_admin_test < database/01_schema_admin.sql

mysql -u ciuser -pcipass ci_admin_test < database/02_seed_admin.sql

mysql -u ciuser -pcipass ci_admin_test < database/03_schema_tasks.sql

mysql -u ciuser -pcipass ci_admin_test < database/04_dummy_tasks.sql


--------------------------------------------------

5. Admin felhasználó létrehozása

php spark seed:admin


Belépési adatok:

nickname: admin

password: admin1234


--------------------------------------------------

6. Szerver indítása

php spark serve --host 0.0.0.0 --port 8080


Megnyitás:

http://localhost:8080/login


--------------------------------------------------

Funkciók


Bejelentkezés

- nickname + jelszó mezők
- szerver oldali validáció
- kliens oldali validáció (Vue)
- CSRF védelem
- hibás adatok esetén hibaüzenet
- sikeres login után átirányítás admin oldalra
- growl (toast) üzenetek


--------------------------------------------------

Menürendszer

A rendszer hierarchikus menüstruktúrát kezel.

Tulajdonságok:

- tetszőleges mélységű menü
- parent-child kapcsolat
- rekurzív felépítés backend oldalon
- rekurzív megjelenítés Vue komponenssel
- új menüpont létrehozása
- validáció
- hibakezelés


API endpointok:

GET  /api/menus/tree

GET  /api/menus

POST /api/menus

PUT  /api/menus/{id}

DELETE /api/menus/{id}


--------------------------------------------------

MySQL feladat

Táblák:

- esemenyek
- jegyek
- tranzakciok
- tranzakcio_elemek
- tranzakcio_fizetesi_modok


Schema:

database/03_schema_tasks.sql


Dummy adatok:

database/04_dummy_tasks.sql


Lekérdezések:

database/05_queries_tasks.sql


Futtatás:

mysql -u ciuser -pcipass ci_admin_test < database/05_queries_tasks.sql


--------------------------------------------------

Projekt felépítés


app/
  Controllers/
    LoginController.php

  Filters/
    AuthFilter.php

  Commands/
    SeedAdminUser.php

  Views/
    login.php
    admin.php


database/
  01_schema_admin.sql
  02_seed_admin.sql
  03_schema_tasks.sql
  04_dummy_tasks.sql
  05_queries_tasks.sql


--------------------------------------------------

Megjegyzések

- A Model réteg nem került használatra a feladat kiírása szerint.
- A logika a LoginController-ben található.
- A frontend Vue.js alapú.
- A design Bootstrap alapú minimális CSS-sel.

