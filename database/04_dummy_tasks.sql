-- 04_dummy_tasks.sql
-- Dummy data for tasks tables (MariaDB compatible)

-- Clean (optional, keeps repeatable)
DELETE FROM tranzakcio_fizetesi_modok;
DELETE FROM tranzakcio_elemek;
UPDATE jegyek SET transaction_id = NULL, status = 'szabad';
DELETE FROM tranzakciok;
DELETE FROM jegyek;
DELETE FROM esemenyek;

-- Events
INSERT INTO esemenyek (id, title, starts_at, location, capacity) VALUES
(1, 'Koncert A',  '2026-01-10 19:00:00', 'Budapest', 100),
(2, 'Koncert B',  '2026-01-25 20:00:00', 'Szeged',   80),
(3, 'Workshop C', '2026-02-05 10:00:00', 'Debrecen', 30),
(4, 'Fesztival D','2026-02-20 18:00:00', 'Pecs',     200);

-- Helper numbers 1..200 (temporary table)
DROP TEMPORARY TABLE IF EXISTS tmp_numbers;
CREATE TEMPORARY TABLE tmp_numbers (n INT PRIMARY KEY);

INSERT INTO tmp_numbers (n) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
(41),(42),(43),(44),(45),(46),(47),(48),(49),(50),
(51),(52),(53),(54),(55),(56),(57),(58),(59),(60),
(61),(62),(63),(64),(65),(66),(67),(68),(69),(70),
(71),(72),(73),(74),(75),(76),(77),(78),(79),(80),
(81),(82),(83),(84),(85),(86),(87),(88),(89),(90),
(91),(92),(93),(94),(95),(96),(97),(98),(99),(100),
(101),(102),(103),(104),(105),(106),(107),(108),(109),(110),
(111),(112),(113),(114),(115),(116),(117),(118),(119),(120),
(121),(122),(123),(124),(125),(126),(127),(128),(129),(130),
(131),(132),(133),(134),(135),(136),(137),(138),(139),(140),
(141),(142),(143),(144),(145),(146),(147),(148),(149),(150),
(151),(152),(153),(154),(155),(156),(157),(158),(159),(160),
(161),(162),(163),(164),(165),(166),(167),(168),(169),(170),
(171),(172),(173),(174),(175),(176),(177),(178),(179),(180),
(181),(182),(183),(184),(185),(186),(187),(188),(189),(190),
(191),(192),(193),(194),(195),(196),(197),(198),(199),(200);

-- Tickets (exactly capacity rows per event)
INSERT INTO jegyek (esemeny_id, status, price_gross)
SELECT 1, 'szabad', 9990.00 FROM tmp_numbers WHERE n <= 100;

INSERT INTO jegyek (esemeny_id, status, price_gross)
SELECT 2, 'szabad', 7990.00 FROM tmp_numbers WHERE n <= 80;

INSERT INTO jegyek (esemeny_id, status, price_gross)
SELECT 3, 'szabad', 19990.00 FROM tmp_numbers WHERE n <= 30;

INSERT INTO jegyek (esemeny_id, status, price_gross)
SELECT 4, 'szabad', 5990.00 FROM tmp_numbers WHERE n <= 200;

-- Transactions (some success/fail across the required dates)
INSERT INTO tranzakciok (id, status, total_gross, created_at) VALUES
(1001, 'sikeres',   19980.00, '2026-01-10 18:30:00'),
(1002, 'sikeres',    7990.00, '2026-01-26 12:10:00'),
(1003, 'sikertelen', 9990.00, '2026-02-01 09:00:00'),
(1004, 'sikeres',   17970.00, '2026-02-20 17:00:00'),
(1005, 'sikeres',   39960.00, '2026-02-28 21:00:00'),
(1006, 'sikeres',    5990.00, '2026-03-01 08:00:00'); -- outside range for first query

-- Payments (note: split payment supported)
INSERT INTO tranzakcio_fizetesi_modok (tranzakcio_id, payment_method, amount_gross) VALUES
(1001, 'bankkartya',      9990.00),
(1001, 'ajandekutalvany', 9990.00),
(1002, 'keszpenz',        7990.00),
(1004, 'szepkartya',     17970.00),
(1005, 'bankkartya',     20000.00),
(1005, 'keszpenz',       19960.00),
(1006, 'bankkartya',      5990.00);

-- Mark sold tickets and link to transactions (LIMIT is OK in MariaDB)
UPDATE jegyek SET status='eladott', transaction_id=1001
WHERE esemeny_id=1 AND status='szabad' LIMIT 2;

UPDATE jegyek SET status='eladott', transaction_id=1002
WHERE esemeny_id=2 AND status='szabad' LIMIT 1;

UPDATE jegyek SET status='eladott', transaction_id=1004
WHERE esemeny_id=4 AND status='szabad' LIMIT 3;

UPDATE jegyek SET status='eladott', transaction_id=1005
WHERE esemeny_id=4 AND status='szabad' LIMIT 6;

-- Transaction items (simple: ticket lines)
INSERT INTO tranzakcio_elemek (tranzakcio_id, jegy_id, qty, unit_gross, line_gross)
SELECT 1001, NULL, 2, 9990.00, 19980.00
UNION ALL SELECT 1002, NULL, 1, 7990.00, 7990.00
UNION ALL SELECT 1004, NULL, 3, 5990.00, 17970.00
UNION ALL SELECT 1005, NULL, 6, 5990.00, 35940.00
UNION ALL SELECT 1005, NULL, 1, 4020.00, 4020.00; -- extra "egyeb" jelleg, de egyszerűsítve itt NULL jegy_id-- 04_dummy_tasks.sql
-- Dummy data for tasks tables (MariaDB compatible)

-- Clean (optional, keeps repeatable)
DELETE FROM tranzakcio_fizetesi_modok;
DELETE FROM tranzakcio_elemek;
UPDATE jegyek SET transaction_id = NULL, status = 'szabad';
DELETE FROM tranzakciok;
DELETE FROM jegyek;
DELETE FROM esemenyek;

-- Events
INSERT INTO esemenyek (id, title, starts_at, location, capacity) VALUES
(1, 'Koncert A',  '2026-01-10 19:00:00', 'Budapest', 100),
(2, 'Koncert B',  '2026-01-25 20:00:00', 'Szeged',   80),
(3, 'Workshop C', '2026-02-05 10:00:00', 'Debrecen', 30),
(4, 'Fesztival D','2026-02-20 18:00:00', 'Pecs',     200);

-- Helper numbers 1..200 (temporary table)
DROP TEMPORARY TABLE IF EXISTS tmp_numbers;
CREATE TEMPORARY TABLE tmp_numbers (n INT PRIMARY KEY);

INSERT INTO tmp_numbers (n) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
(41),(42),(43),(44),(45),(46),(47),(48),(49),(50),
(51),(52),(53),(54),(55),(56),(57),(58),(59),(60),
(61),(62),(63),(64),(65),(66),(67),(68),(69),(70),
(71),(72),(73),(74),(75),(76),(77),(78),(79),(80),
(81),(82),(83),(84),(85),(86),(87),(88),(89),(90),
(91),(92),(93),(94),(95),(96),(97),(98),(99),(100),
(101),(102),(103),(104),(105),(106),(107),(108),(109),(110),
(111),(112),(113),(114),(115),(116),(117),(118),(119),(120),
(121),(122),(123),(124),(125),(126),(127),(128),(129),(130),
(131),(132),(133),(134),(135),(136),(137),(138),(139),(140),
(141),(142),(143),(144),(145),(146),(147),(148),(149),(150),
(151),(152),(153),(154),(155),(156),(157),(158),(159),(160),
(161),(162),(163),(164),(165),(166),(167),(168),(169),(170),
(171),(172),(173),(174),(175),(176),(177),(178),(179),(180),
(181),(182),(183),(184),(185),(186),(187),(188),(189),(190),
(191),(192),(193),(194),(195),(196),(197),(198),(199),(200);

-- Tickets (exactly capacity rows per event)
INSERT INTO jegyek (esemeny_id, status, price_gross)
SELECT 1, 'szabad', 9990.00 FROM tmp_numbers WHERE n <= 100;

INSERT INTO jegyek (esemeny_id, status, price_gross)
SELECT 2, 'szabad', 7990.00 FROM tmp_numbers WHERE n <= 80;

INSERT INTO jegyek (esemeny_id, status, price_gross)
SELECT 3, 'szabad', 19990.00 FROM tmp_numbers WHERE n <= 30;

INSERT INTO jegyek (esemeny_id, status, price_gross)
SELECT 4, 'szabad', 5990.00 FROM tmp_numbers WHERE n <= 200;

-- Transactions (some success/fail across the required dates)
INSERT INTO tranzakciok (id, status, total_gross, created_at) VALUES
(1001, 'sikeres',   19980.00, '2026-01-10 18:30:00'),
(1002, 'sikeres',    7990.00, '2026-01-26 12:10:00'),
(1003, 'sikertelen', 9990.00, '2026-02-01 09:00:00'),
(1004, 'sikeres',   17970.00, '2026-02-20 17:00:00'),
(1005, 'sikeres',   39960.00, '2026-02-28 21:00:00'),
(1006, 'sikeres',    5990.00, '2026-03-01 08:00:00'); -- outside range for first query

-- Payments (note: split payment supported)
INSERT INTO tranzakcio_fizetesi_modok (tranzakcio_id, payment_method, amount_gross) VALUES
(1001, 'bankkartya',      9990.00),
(1001, 'ajandekutalvany', 9990.00),
(1002, 'keszpenz',        7990.00),
(1004, 'szepkartya',     17970.00),
(1005, 'bankkartya',     20000.00),
(1005, 'keszpenz',       19960.00),
(1006, 'bankkartya',      5990.00);

-- Mark sold tickets and link to transactions (LIMIT is OK in MariaDB)
UPDATE jegyek SET status='eladott', transaction_id=1001
WHERE esemeny_id=1 AND status='szabad' LIMIT 2;

UPDATE jegyek SET status='eladott', transaction_id=1002
WHERE esemeny_id=2 AND status='szabad' LIMIT 1;

UPDATE jegyek SET status='eladott', transaction_id=1004
WHERE esemeny_id=4 AND status='szabad' LIMIT 3;

UPDATE jegyek SET status='eladott', transaction_id=1005
WHERE esemeny_id=4 AND status='szabad' LIMIT 6;

-- Transaction items (simple: ticket lines)
INSERT INTO tranzakcio_elemek (tranzakcio_id, jegy_id, qty, unit_gross, line_gross)
SELECT 1001, NULL, 2, 9990.00, 19980.00
UNION ALL SELECT 1002, NULL, 1, 7990.00, 7990.00
UNION ALL SELECT 1004, NULL, 3, 5990.00, 17970.00
UNION ALL SELECT 1005, NULL, 6, 5990.00, 35940.00
UNION ALL SELECT 1005, NULL, 1, 4020.00, 4020.00; -- extra "egyeb" jelleg, de egyszerűsítve itt NULL jegy_id
