<?php

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require_once dirname(__DIR__, 3) . '/config/config.inc.php';
require_once __DIR__ . '/variants.php';

function installOmnibus(Omnibus $module, Db $db): bool
{
    $prefix = _DB_PREFIX_;
    // The payment snapshot can leave group and hook associations for removed module IDs.
    $nextId = (int) $db->getValue("SELECT 1 + GREATEST(
        COALESCE((SELECT MAX(id_module) FROM `{$prefix}module_group`), 0),
        COALESCE((SELECT MAX(id_module) FROM `{$prefix}hook_module`), 0),
        COALESCE((SELECT MAX(id_module) FROM `{$prefix}hook_module_exceptions`), 0)
    )", false);
    $autoIncrement = (int) $db->getValue("SELECT AUTO_INCREMENT FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '{$prefix}module'", false);
    if ($nextId > $autoIncrement && !$db->execute("ALTER TABLE `{$prefix}module` AUTO_INCREMENT = $nextId")) {
        return false;
    }

    return $module->install();
}

function seedDiscount(Omnibus $module, Product $product, int $shopId, int $percent): void
{
    $productId = (int) $product->id;
    $reduction = $percent / 100;
    $promotion = $module->getPromotion($productId);
    if ($promotion) {
        $price = new SpecificPrice((int) $promotion['id_specific_price']);
        if (!Validate::isLoadedObject($price) || (int) $price->id_product !== $productId
            || (int) $price->id_shop !== $shopId || $price->reduction_type !== 'percentage') {
            throw new RuntimeException("Missing native percentage promotion for {$product->reference}.");
        }
        $previousReduction = (float) $price->reduction;
        if ($previousReduction === $reduction) {
            return;
        }

        $module->recordPrice($product, $previousReduction);
        $price->reduction = $reduction;
        if (!$price->update()) {
            throw new RuntimeException("Could not update the promotion for {$product->reference}.");
        }

        if ($reduction > $previousReduction) {
            $module->savePromotion($product, $price);
        }
        $module->recordPrice($product, $reduction);

        return;
    }

    if ($product->hasAttributes() || !$product->active || !$product->available_for_order || !$product->show_price
        || (float) $product->price <= 0) {
        throw new RuntimeException("{$product->reference} must be an active, purchasable simple product with a price.");
    }
    if (SpecificPrice::getByProductId($productId)) {
        throw new RuntimeException("{$product->reference} already has a specific price. Expected the first promotion.");
    }

    $module->recordPrice($product);

    $price = new SpecificPrice();
    $price->id_product = $productId;
    $price->id_shop = $shopId;
    $price->id_product_attribute = 0;
    $price->id_currency = 0;
    $price->id_country = 0;
    $price->id_group = 0;
    $price->id_customer = 0;
    $price->price = -1;
    $price->from_quantity = 1;
    $price->reduction = $reduction;
    $price->reduction_type = 'percentage';
    $price->from = SpecificPrice::ORDER_DEFAULT_DATE;
    $price->to = SpecificPrice::ORDER_DEFAULT_DATE;
    if (!$price->add()) {
        throw new RuntimeException("Could not add a promotion to {$product->reference}.");
    }

    $module->savePromotion($product, $price);
    $module->recordPrice($product, $reduction);
}

try {
    $context = Context::getContext();
    $shopId = (int) $context->shop->id;
    Shop::setContext(Shop::CONTEXT_SHOP, $shopId);
    $languageId = (int) Configuration::get('PS_LANG_DEFAULT');
    $context->language = new Language($languageId);
    $kernel = new AppKernel(_PS_MODE_DEV_ ? 'dev' : 'prod', _PS_MODE_DEV_);
    $kernel->boot();
    $db = Db::getInstance();
    $lock = 'omnibus-' . md5(_DB_NAME_ . ':' . _DB_PREFIX_ . ':' . $shopId);
    if (!(int) $db->getValue("SELECT GET_LOCK('$lock', 10)", false)) {
        throw new RuntimeException('Could not lock the promotion configuration.');
    }

    try {
        $module = Module::getInstanceByName('omnibus');
        if (!$module || (!Module::isInstalled('omnibus') && !installOmnibus($module, $db))
            || (!Module::isEnabled('omnibus') && !$module->enable()) || !$module->registerVariantSelector()) {
            throw new RuntimeException('Could not install or enable the Omnibus module.');
        }
        if (($argv[1] ?? '') === '--install-only') {
            echo "Omnibus module ready.\n";
            return;
        }

        $catalog = require dirname(__DIR__) . '/catalog.php';
        $references = array_keys($catalog['discounts']);
        foreach ($catalog['variant_groups'] as $group) {
            $references = array_merge($references, array_values($group['options']));
        }
        $products = [];
        foreach ($references as $reference) {
            $reference = (string) $reference;
            $product = new Product((int) Product::getIdByReference($reference), false, $languageId, $shopId);
            if (!Validate::isLoadedObject($product)) {
                throw new RuntimeException("Product {$reference} not found. Run make import first.");
            }
            $products[$reference] = $product;
        }

        if (!$db->execute('START TRANSACTION')) {
            throw new RuntimeException('Could not start the promotion configuration transaction.');
        }
        try {
            foreach ($catalog['discounts'] as $reference => $percent) {
                seedDiscount($module, $products[$reference], $shopId, $percent);
            }
            $sourcePath = $argv[1] ?? '/tmp/omnibus-products.json';
            $sourceProducts = loadVariantSourceProducts($sourcePath);
            foreach ($catalog['variant_groups'] as $group) {
                restoreVariantProducts($group['options'], $products, $sourceProducts, $shopId);
            }
            if (!$db->execute('COMMIT')) {
                throw new RuntimeException('Could not commit the promotion configuration.');
            }
        } catch (Throwable $error) {
            $db->execute('ROLLBACK');
            throw $error;
        }

        printf("Configured %d promotions and %d variant groups.\n",
            count($catalog['discounts']), count($catalog['variant_groups']));
    } finally {
        $db->getValue("SELECT RELEASE_LOCK('$lock')", false);
    }
} catch (Throwable $error) {
    fwrite(STDERR, $error->getMessage() . PHP_EOL);
    exit(1);
}
