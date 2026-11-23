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

-- 4. Set PLN as default currency in configuration and deactivate other currencies
DELETE FROM ps_configuration WHERE name = 'PS_CURRENCY_DEFAULT';
INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
VALUES (NULL, NULL, 'PS_CURRENCY_DEFAULT', '3', NOW(), NOW());
UPDATE ps_currency SET active = 0 WHERE iso_code != 'PLN';

-- 5. Configure Bank Wire module settings
DELETE FROM ps_configuration WHERE name IN ('BANK_WIRE_DETAILS', 'BANK_WIRE_OWNER', 'BANK_WIRE_ADDRESS', 'BANK_WIRE_RESERVATION_DAYS');
INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
VALUES
(NULL, NULL, 'BANK_WIRE_DETAILS', 'Nr rachunku: 88 1050 0000 0000 0000 1234 5678 (Bank Millennium)', NOW(), NOW()),
(NULL, NULL, 'BANK_WIRE_OWNER', 'Domitek Sp. z o.o.', NOW(), NOW()),
(NULL, NULL, 'BANK_WIRE_ADDRESS', 'Domitek Sp. z o.o., Polska', NOW(), NOW()),
(NULL, NULL, 'BANK_WIRE_RESERVATION_DAYS', '7', NOW(), NOW());

-- 6. Activate payment modules in ps_module and deactivate check payment
UPDATE ps_module SET active = 1 WHERE name IN ('ps_wirepayment', 'ps_cashondelivery');
UPDATE ps_module SET active = 0 WHERE name = 'ps_checkpayment';
DELETE FROM ps_module_shop WHERE id_module IN (SELECT id_module FROM ps_module WHERE name = 'ps_checkpayment');

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
    UNION SELECT 5
    UNION SELECT 6
) c
WHERE m.name IN ('ps_wirepayment', 'ps_cashondelivery');

-- 11. Mailpit SMTP Configuration
DELETE FROM ps_configuration WHERE name IN (
    'PS_MAIL_METHOD',
    'PS_MAIL_SERVER',
    'PS_MAIL_USER',
    'PS_MAIL_PASSWD',
    'PS_MAIL_SMTP_ENCRYPTION',
    'PS_MAIL_SMTP_PORT',
    'PS_MAIL_TYPE',
    'PS_MAIL_EMAIL_MESSAGE'
);

INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
VALUES
(NULL, NULL, 'PS_MAIL_METHOD', '2', NOW(), NOW()),
(NULL, NULL, 'PS_MAIL_SERVER', 'mailpit', NOW(), NOW()),
(NULL, NULL, 'PS_MAIL_USER', '', NOW(), NOW()),
(NULL, NULL, 'PS_MAIL_PASSWD', '', NOW(), NOW()),
(NULL, NULL, 'PS_MAIL_SMTP_ENCRYPTION', 'off', NOW(), NOW()),
(NULL, NULL, 'PS_MAIL_SMTP_PORT', '1025', NOW(), NOW()),
(NULL, NULL, 'PS_MAIL_TYPE', '3', NOW(), NOW()),
(NULL, NULL, 'PS_MAIL_EMAIL_MESSAGE', '1', NOW(), NOW()),
(NULL, 1, 'PS_MAIL_METHOD', '2', NOW(), NOW()),
(NULL, 1, 'PS_MAIL_SERVER', 'mailpit', NOW(), NOW()),
(NULL, 1, 'PS_MAIL_USER', '', NOW(), NOW()),
(NULL, 1, 'PS_MAIL_PASSWD', '', NOW(), NOW()),
(NULL, 1, 'PS_MAIL_SMTP_ENCRYPTION', 'off', NOW(), NOW()),
(NULL, 1, 'PS_MAIL_SMTP_PORT', '1025', NOW(), NOW()),
(NULL, 1, 'PS_MAIL_TYPE', '3', NOW(), NOW()),
(NULL, 1, 'PS_MAIL_EMAIL_MESSAGE', '1', NOW(), NOW());
