# Jegyx1 próbafeladat – CodeIgniter 4 admin alkalmazás

Ez a projekt a Jegyx1 próbafeladat megoldása.

A rendszer egy egyszerű admin alkalmazás CodeIgniter 4 keretrendszerben, Vue.js frontenddel.
A telepítés automatizált, egyetlen script futtatásával elvégezhető.

Az install script telepíti a szükséges komponenseket, létrehozza az adatbázist, importálja az adatokat és elindítja az alkalmazást.


--------------------------------------------------

## Követelmények

A projekt Linux vagy WSL környezetben fut.

Ajánlott:

- WSL Ubuntu
- Internet kapcsolat

Nem szükséges előre telepíteni:

- PHP
- Composer
- MySQL / MariaDB
- Git

Az install script automatikusan telepíti a szükséges csomagokat.


--------------------------------------------------

## Projekt letöltése

WSL terminálban:

mkdir -p ~/projects
cd ~/projects

git clone https://github.com/sidaric/jegyx1-test.git

cd jegyx1-test


--------------------------------------------------

## Automatikus telepítés

A teljes rendszer telepíthető egyetlen paranccsal.

Első futtatás előtt:

chmod +x install.sh


Telepítés indítása:

./install.sh
(bash install.sh)

A script automatikusan elvégzi:

- szükséges csomagok telepítése (PHP, Composer, MariaDB)
- MariaDB elindítása
- adatbázis létrehozása
- adatbázis user létrehozása
- .env fájl létrehozása
- composer install futtatása
- adatbázis schema importálása
- dummy adatok feltöltése
- admin felhasználó létrehozása
- fejlesztői szerver elindítása


--------------------------------------------------

## Az alkalmazás elérése

Telepítés után az alkalmazás automatikusan elindul.

Böngészőben:

http://localhost:8080/login


Belépési adatok:

nickname: admin
password: admin1234


--------------------------------------------------

## A szerver leállítása

A szerver addig fut amíg a terminál nyitva van.

Leállítás:

CTRL + C


Újraindítás:

php spark serve --host 0.0.0.0 --port 8080


--------------------------------------------------

## Funkciók


Bejelentkezés

- nickname és jelszó mező
- szerver oldali validáció
- kliens oldali validáció (Vue)
- CSRF védelem
- hibás belépés esetén hibaüzenet
- sikeres belépés után átirányítás
- toast (growl) üzenetek


--------------------------------------------------

Menürendszer

Az admin felületen egy dinamikus hierarchikus menürendszer kezelhető.

Tulajdonságok:

- tetszőleges mélységű menü
- parent-child kapcsolat
- rekurzív felépítés backend oldalon
- rekurzív megjelenítés Vue komponenssel
- új menüpont létrehozása
- űrlap validáció
- hibakezelés


API endpointok:

GET    /api/menus/tree
GET    /api/menus
POST   /api/menus
PUT    /api/menus/{id}
DELETE /api/menus/{id}


--------------------------------------------------

## MySQL feladat

A feladatban szereplő táblák:

- esemenyek
- jegyek
- tranzakciok
- tranzakcio_elemek
- tranzakcio_fizetesi_modok


Schema fájl:

database/03_schema_tasks.sql


Dummy adatok:

database/04_dummy_tasks.sql


Lekérdezések:

database/05_queries_tasks.sql


Lekérdezések futtatása:

mysql -u ciuser -pcipass ci_admin_test < database/05_queries_tasks.sql


--------------------------------------------------

## Projekt felépítés


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


install.sh


--------------------------------------------------

## Gyors teszt

Telepítés után:

1) megnyitás:

http://localhost:8080/login


2) belépés:

admin / admin1234


3) menüpont létrehozása az admin oldalon


--------------------------------------------------

## Megjegyzések

A Model réteg szándékosan nincs használva a feladat kiírása szerint.

Az alkalmazás logikája a LoginController-ben található.

A frontend Vue.js alapú.

A design Bootstrap alapú minimális CSS-sel.
