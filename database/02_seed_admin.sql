-- 02_seed_admin.sql
-- Dummy menu + demo user placeholder

-- Dummy menu
INSERT INTO menus (id, parent_id, title, url, sort_order, is_active) VALUES
(1, NULL, 'Dashboard', '/admin', 10, 1),
(2, NULL, 'Beallitasok', NULL, 20, 1),
(3, 2, 'Felhasznalok', '/admin/users', 10, 1),
(4, 2, 'Menuk', '/admin/menus', 20, 1)
ON DUPLICATE KEY UPDATE title=VALUES(title), url=VALUES(url), sort_order=VALUES(sort_order), is_active=VALUES(is_active);

-- NOTE: user insert will be done via CI (password_hash), not plain SQL.
