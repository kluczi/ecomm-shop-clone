-- PrestaShop 8 Payment and Currency Configuration
-- Idempotent configuration for Polish Złoty (PLN) and Payment Modules (Bank Wire, Cash on Delivery)

-- 1. Ensure PLN (ID 3, ISO 985) is active
INSERT INTO ps_currency (id_currency, name, iso_code, numeric_iso_code, `precision`, conversion_rate, deleted, active, unofficial, modified)
VALUES (3, 'Polski złoty', 'PLN', '985', 2, 1.000000, 0, 1, 0, 0)
ON DUPLICATE KEY UPDATE name = 'Polski złoty', active = 1, deleted = 0, conversion_rate = 1.000000;

-- 2. Currency language entries for PLN
INSERT INTO ps_currency_lang (id_currency, id_lang, name, symbol, pattern)
VALUES 
(3, 1, 'złoty polski', 'zł', ''),
(3, 2, 'Polish Zloty', 'zł', '')
ON DUPLICATE KEY UPDATE name = VALUES(name), symbol = VALUES(symbol);

-- 3. Link currency PLN to Shop 1
INSERT IGNORE INTO ps_currency_shop (id_currency, id_shop, conversion_rate)
VALUES (3, 1, 1.000000);

-- 4. Set PLN as default currency in configuration
DELETE FROM ps_configuration WHERE name = 'PS_CURRENCY_DEFAULT';
INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
VALUES (NULL, NULL, 'PS_CURRENCY_DEFAULT', '3', NOW(), NOW());

-- 5. Configure Bank Wire module settings
DELETE FROM ps_configuration WHERE name IN ('BANK_WIRE_DETAILS', 'BANK_WIRE_OWNER', 'BANK_WIRE_ADDRESS', 'BANK_WIRE_RESERVATION_DAYS');
INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
VALUES
(NULL, NULL, 'BANK_WIRE_DETAILS', 'Przelew na rachunek bankowy', NOW(), NOW()),
(NULL, NULL, 'BANK_WIRE_OWNER', 'Domitek Sp. z o.o.', NOW(), NOW()),
(NULL, NULL, 'BANK_WIRE_ADDRESS', 'Bank PKO BP: 12 1020 0000 0000 0000 0000 0000', NOW(), NOW()),
(NULL, NULL, 'BANK_WIRE_RESERVATION_DAYS', '7', NOW(), NOW());

-- 6. Activate payment modules in ps_module and ps_module_shop
UPDATE ps_module SET active = 1 WHERE name IN ('ps_wirepayment', 'ps_cashondelivery');

INSERT IGNORE INTO ps_module_shop (id_module, id_shop, enable_device)
SELECT id_module, 1, 7
FROM ps_module
WHERE name IN ('ps_wirepayment', 'ps_cashondelivery');

-- 7. Currency restrictions: link payment modules to PLN (id_currency = 3)
INSERT IGNORE INTO ps_module_currency (id_module, id_shop, id_currency)
SELECT id_module, 1, 3
FROM ps_module
WHERE name IN ('ps_wirepayment', 'ps_cashondelivery');

-- 8. Country restrictions: link payment modules to Poland (iso_code = 'PL')
INSERT IGNORE INTO ps_module_country (id_module, id_shop, id_country)
SELECT m.id_module, 1, c.id_country
FROM ps_module m
CROSS JOIN ps_country c
WHERE m.name IN ('ps_wirepayment', 'ps_cashondelivery')
  AND c.iso_code = 'PL';

-- 9. Customer group restrictions: link payment modules to all customer groups
INSERT IGNORE INTO ps_module_group (id_module, id_shop, id_group)
SELECT m.id_module, 1, g.id_group
FROM ps_module m
CROSS JOIN ps_group g
WHERE m.name IN ('ps_wirepayment', 'ps_cashondelivery');

-- 10. Carrier restrictions: link payment modules to ALL active carriers (DPD, InPost)
INSERT IGNORE INTO ps_module_carrier (id_module, id_shop, id_reference)
SELECT m.id_module, 1, c.id_reference
FROM ps_module m
CROSS JOIN (
    SELECT DISTINCT id_reference FROM ps_carrier WHERE deleted = 0
) c
WHERE m.name IN ('ps_wirepayment', 'ps_cashondelivery');
