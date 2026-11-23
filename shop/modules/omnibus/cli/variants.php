<?php

use PrestaShop\PrestaShop\Core\Domain\Product\ValueObject\ProductType;

if (!defined('_PS_VERSION_')) {
    exit;
}

function loadVariantSourceProducts(string $path): array
{
    static $catalogues = [];
    if (isset($catalogues[$path])) {
        return $catalogues[$path];
    }
    if (!is_file($path) || !is_readable($path)) {
        throw new RuntimeException('Missing scraper results for variant migration. Run make promotions from the repository.');
    }

    $products = json_decode(file_get_contents($path), true, 512, JSON_THROW_ON_ERROR);

    return $catalogues[$path] = array_column($products, null, 'sku');
}

function moveVariantReferences(Combination $combination, int $productId, int $shopId): void
{
    $db = Db::getInstance();
    $table = _DB_PREFIX_ . 'cart_product';
    $parentId = (int) $combination->id_product;
    $combinationId = (int) $combination->id;

    // Merge the quantities if the cart already contains the original SKU.
    if (!$db->execute("INSERT INTO `$table`
        (id_cart, id_product, id_address_delivery, id_shop, id_product_attribute, id_customization, quantity, date_add)
        SELECT legacy.id_cart, $productId, legacy.id_address_delivery, legacy.id_shop, 0,
            legacy.id_customization, legacy.quantity, legacy.date_add
        FROM `$table` AS legacy
        WHERE legacy.id_product = $parentId AND legacy.id_product_attribute = $combinationId AND legacy.id_shop = $shopId
        ON DUPLICATE KEY UPDATE quantity = `$table`.quantity + VALUES(quantity)")
        || !$db->update('customization', ['id_product' => $productId, 'id_product_attribute' => 0],
            "id_product = $parentId AND id_product_attribute = $combinationId")
        // Keep the original order details while routing reorders and refunds to the current SKU.
        || !$db->update('order_detail', ['product_id' => $productId, 'product_attribute_id' => 0],
            "product_id = $parentId AND product_attribute_id = $combinationId AND id_shop = $shopId")) {
        throw new RuntimeException("Could not transfer cart and order references for {$combination->reference}.");
    }
}

function detachCopiedVariantImages(Combination $combination, Product $source, Product $parent, int $shopId): void
{
    if ($source->id === $parent->id || !($cover = Image::getCover((int) $source->id))) {
        return;
    }

    $original = new Image((int) $cover['id_image']);
    $originalPath = _PS_PRODUCT_IMG_DIR_ . $original->getExistingImgPath() . '.jpg';
    if (!is_file($originalPath)) {
        return;
    }

    $originalHash = hash_file('sha256', $originalPath);
    $parentCover = Image::getCover((int) $parent->id);
    foreach ($combination->getWsImages() as $association) {
        $image = new Image((int) $association['id']);
        $path = _PS_PRODUCT_IMG_DIR_ . $image->getExistingImgPath() . '.jpg';
        if ((int) $image->id_product === (int) $parent->id && (int) $image->id !== (int) ($parentCover['id_image'] ?? 0)
            && is_file($path) && $originalHash !== false && hash_file('sha256', $path) === $originalHash) {
            // Hide only the old copy. Keep the original files and image IDs available.
            if (!Db::getInstance()->delete('image_shop', 'id_image = ' . (int) $image->id . ' AND id_shop = ' . $shopId)) {
                throw new RuntimeException("Could not detach the copied image for {$source->reference}.");
            }
        }
    }
}

function restoreVariantProducts(array $options, array $products, string $sourcePath, int $shopId): void
{
    $parent = $products[reset($options)];
    $parentId = (int) $parent->id;
    $legacyAliases = array_filter($options, static function (string $reference) use ($products, $parentId): bool {
        $product = $products[$reference];

        return $product->redirect_type === '301-product' && (int) $product->id_type_redirected === $parentId;
    });
    if (!$legacyAliases) {
        return;
    }

    $sourceProducts = loadVariantSourceProducts($sourcePath);
    foreach ($options as $reference) {
        if (!isset($sourceProducts[$reference])) {
            throw new RuntimeException("Product {$reference} is missing from the scraper results.");
        }
    }

    $combinations = [];
    foreach (Product::getProductAttributesIds($parentId, true) as $row) {
        $combination = new Combination((int) $row['id_product_attribute'], null, $shopId);
        $combinations[$combination->reference] = $combination;
    }
    if (count($combinations) !== count($options) || array_diff($options, array_keys($combinations))) {
        throw new RuntimeException("The existing combinations for {$parent->reference} do not match the previous configuration.");
    }

    $db = Db::getInstance();
    $stocks = [];
    foreach ($combinations as $reference => $combination) {
        $stockId = (int) StockAvailable::getStockAvailableIdByProductId($parentId, (int) $combination->id, $shopId);
        $stock = $db->getRow((new DbQuery())->select('quantity, reserved_quantity, physical_quantity')
            ->from('stock_available')->where("id_stock_available = $stockId"));
        if (!$stock) {
            throw new RuntimeException("Could not read the old stock for {$reference}.");
        }
        $stocks[$reference] = array_map('intval', $stock);

        moveVariantReferences($combination, (int) $products[$reference]->id, $shopId);
        detachCopiedVariantImages($combination, $products[$reference], $parent, $shopId);
        if (!$combination->delete()) {
            throw new RuntimeException("Could not remove the old combination for {$reference}.");
        }
    }

    foreach ($options as $reference) {
        $product = $products[$reference];
        $source = $sourceProducts[$reference];
        $product->name = trim($source['name']);
        $product->description = $source['description'];
        $product->link_rewrite = Tools::str2url($product->name);
        $product->product_type = ProductType::TYPE_STANDARD;
        $product->cache_default_attribute = 0;
        $product->active = true;
        $product->available_for_order = true;
        $product->visibility = 'both';
        $product->redirect_type = '';
        $product->id_type_redirected = 0;
        if (!$product->update()) {
            throw new RuntimeException("Could not restore the product page for {$reference}.");
        }

        $productId = (int) $product->id;
        $stock = $stocks[$reference];
        StockAvailable::setQuantity($productId, 0, $stock['quantity'], $shopId, false);
        $stockId = (int) StockAvailable::getStockAvailableIdByProductId($productId, 0, $shopId);
        if (!$stockId || !$db->update('stock_available', [
            'reserved_quantity' => $stock['reserved_quantity'],
            'physical_quantity' => $stock['physical_quantity'],
        ], "id_stock_available = $stockId")
            || (int) StockAvailable::getQuantityAvailableByProduct($productId, 0, $shopId) !== $stock['quantity']
            || !Search::indexation(false, $productId)) {
            throw new RuntimeException("Could not restore stock or indexing for {$reference}.");
        }
    }
}
