-- Konfiguracja motywu potomnego i wyglądu sklepu Domitek (Wariant A - TopMarket.pl)

-- 1. Aktywacja motywu potomnego w ps_shop
UPDATE ps_shop SET theme_name = 'topmarket-child' WHERE id_shop = 1;

-- 2. Wpis w ps_configuration dla motywu
INSERT INTO ps_configuration (name, id_shop_group, id_shop, value, date_add, date_upd)
VALUES ('PS_THEME_NAME', NULL, 1, 'topmarket-child', NOW(), NOW())
ON DUPLICATE KEY UPDATE value = 'topmarket-child', date_upd = NOW();

-- 3. Dodanie wyróżnionych pozycji PROMOCJE i NOWOŚCI do menu górnego (na wzór TopMarket.pl)
INSERT INTO ps_linksmenutop (id_linksmenutop, id_shop, new_window) VALUES (1, 1, 0)
ON DUPLICATE KEY UPDATE new_window = 0;

INSERT INTO ps_linksmenutop_lang (id_linksmenutop, id_lang, id_shop, label, link)
VALUES
(1, 1, 1, 'PROMOCJE', '/promocje'),
(1, 2, 1, 'PROMOTIONS', '/en/promocje')
ON DUPLICATE KEY UPDATE label = VALUES(label), link = VALUES(link);

INSERT INTO ps_linksmenutop (id_linksmenutop, id_shop, new_window) VALUES (2, 1, 0)
ON DUPLICATE KEY UPDATE new_window = 0;

INSERT INTO ps_linksmenutop_lang (id_linksmenutop, id_lang, id_shop, label, link)
VALUES
(2, 1, 1, 'NOWOŚCI', '/nowe-produkty'),
(2, 2, 1, 'NEW PRODUCTS', '/en/nowe-produkty')
ON DUPLICATE KEY UPDATE label = VALUES(label), link = VALUES(link);

SET @cat_items = (
  SELECT GROUP_CONCAT(CONCAT('CAT', c.id_category) ORDER BY cs.position, c.id_category SEPARATOR ',')
  FROM ps_category c
  INNER JOIN ps_category_shop cs ON cs.id_category = c.id_category AND cs.id_shop = 1
  WHERE c.id_parent = 2 AND c.active = 1
);

UPDATE ps_configuration
SET value = CONCAT_WS(',', 'LNK1', NULLIF(@cat_items, ''), 'LNK2')
WHERE name = 'MOD_BLOCKTOPMENU_ITEMS';

-- 4. Konfiguracja modułu banera (link bezpieczny niezależnie od ID kategorii)
UPDATE ps_configuration SET value = 'banner-top-cut.webp' WHERE name = 'BANNER_IMG';
UPDATE ps_configuration SET value = '/promocje' WHERE name = 'BANNER_LINK';
UPDATE ps_configuration SET value = 'Ogromny wybór narzędzi ogrodowych i elektronarzędzi w sklepie Domitek' WHERE name = 'BANNER_DESC';

-- 5. Drzewo kategorii w sidebarze (podkategorie bieżącej kategorii zamiast Strony głównej)
DELETE FROM ps_configuration WHERE name = 'BLOCK_CATEG_ROOT_CATEGORY';
INSERT INTO ps_configuration (name, id_shop_group, id_shop, value, date_add, date_upd)
VALUES ('BLOCK_CATEG_ROOT_CATEGORY', NULL, NULL, '3', NOW(), NOW());

-- 6. Usunięcie zduplikowanego hooka ps_searchbar z displayTop (renderowany wyłącznie przez displaySearch w header.tpl)
DELETE FROM ps_hook_module
WHERE id_module = (SELECT id_module FROM ps_module WHERE name = 'ps_searchbar')
  AND id_hook = (SELECT id_hook FROM ps_hook WHERE name = 'displayTop');
