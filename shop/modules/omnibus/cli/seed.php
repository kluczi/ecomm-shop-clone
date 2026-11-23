<?php

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require_once dirname(__DIR__, 3) . '/config/config.inc.php';
require_once __DIR__ . '/variants.php';

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
        if (!$module || (!Module::isInstalled('omnibus') && !$module->install())
            || (!Module::isEnabled('omnibus') && !$module->enable()) || !$module->registerVariantHooks()) {
            throw new RuntimeException('Could not install or enable the Omnibus module.');
        }
        if (($argv[1] ?? '') === '--install-only') {
            echo "Omnibus module ready.\n";
            return;
        }

        $catalog = require dirname(__DIR__) . '/catalog.php';
        $references = array_keys($catalog['discounts']);
        foreach ($catalog['variant_groups'] as $group) {
            $references = array_merge($references, array_column($group['options'], 0));
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
        $copiedImages = [];
        try {
            foreach ($catalog['discounts'] as $reference => $percent) {
                seedDiscount($module, $products[$reference], $shopId, $percent);
            }
            foreach ($catalog['variant_groups'] as $group) {
                seedVariantGroup($group, $products, $shopId, $languageId, $copiedImages);
            }
            if (!$db->execute('COMMIT')) {
                throw new RuntimeException('Could not commit the promotion configuration.');
            }
        } catch (Throwable $error) {
            $db->execute('ROLLBACK');
            foreach ($copiedImages as $image) {
                $image->deleteImage();
            }
            throw $error;
        }

        printf("Configured %d promotions and %d products with variants.\n",
            count($catalog['discounts']), count($catalog['variant_groups']));
    } finally {
        $db->getValue("SELECT RELEASE_LOCK('$lock')", false);
    }
} catch (Throwable $error) {
    fwrite(STDERR, $error->getMessage() . PHP_EOL);
    exit(1);
}
