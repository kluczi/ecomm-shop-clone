-- Enable Webservice in PrestaShop configuration
INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
VALUES (NULL, NULL, 'PS_WEBSERVICE', '1', NOW(), NOW())
ON DUPLICATE KEY UPDATE value = '1', date_upd = NOW();

-- Create Webservice Account for API key passed in @api_key
INSERT INTO ps_webservice_account (`key`, description, class_name, is_module, active)
VALUES (@api_key, 'Import katalogu i stanów magazynowych', 'WebserviceRequest', 0, 1)
ON DUPLICATE KEY UPDATE active = 1, description = 'Import katalogu i stanów magazynowych';

-- Associate account with shop 1
INSERT IGNORE INTO ps_webservice_account_shop (id_webservice_account, id_shop)
SELECT id_webservice_account, 1
FROM ps_webservice_account
WHERE `key` = @api_key;

-- Grant permissions for catalog, images, stock, and tax resources
INSERT IGNORE INTO ps_webservice_permission (resource, method, id_webservice_account)
SELECT r.resource, m.method, a.id_webservice_account
FROM ps_webservice_account a
CROSS JOIN (
    SELECT 'categories' AS resource
    UNION SELECT 'combinations'
    UNION SELECT 'images'
    UNION SELECT 'manufacturers'
    UNION SELECT 'product_feature_values'
    UNION SELECT 'product_features'
    UNION SELECT 'products'
    UNION SELECT 'stock_availables'
    UNION SELECT 'tax_rule_groups'
    UNION SELECT 'tax_rules'
    UNION SELECT 'taxes'
) r
CROSS JOIN (
    SELECT 'GET' AS method
    UNION SELECT 'POST'
    UNION SELECT 'PUT'
    UNION SELECT 'PATCH'
    UNION SELECT 'DELETE'
    UNION SELECT 'HEAD'
) m
WHERE a.`key` = @api_key;
