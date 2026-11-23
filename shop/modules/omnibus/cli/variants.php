<?php

use PrestaShop\PrestaShop\Core\Domain\Product\ValueObject\ProductType;

if (!defined('_PS_VERSION_')) {
    exit;
}

function loadVariantSourceProducts(string $path): array
{
    if (!is_readable($path)) {
        throw new RuntimeException('Missing scraper results. Run make promotions from the repository.');
    }

    $products = json_decode(file_get_contents($path), true, 512, JSON_THROW_ON_ERROR);

    return array_column($products, null, 'sku');
}

function moveVariantCartLines(Combination $combination, int $productId, int $shopId): void
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
            "id_product = $parentId AND id_product_attribute = $combinationId")) {
        throw new RuntimeException("Could not transfer carts for {$combination->reference}.");
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

function restoreVariantProducts(array $options, array $products, array $sourceProducts, int $shopId): void
{
    foreach ($options as $reference) {
        if (!isset($sourceProducts[$reference])) {
            throw new RuntimeException("Product {$reference} is missing from the scraper results.");
        }
    }

    $parent = $products[reset($options)];
    $parentId = (int) $parent->id;
    $legacyAliases = array_filter($options, static function (string $reference) use ($products, $parentId): bool {
        $product = $products[$reference];

        return $product->redirect_type === '301-product' && (int) $product->id_type_redirected === $parentId;
    });
    if (!$legacyAliases) {
        return;
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
    $ids = implode(',', array_map(static fn (Combination $combination) => (int) $combination->id, $combinations));
    if ($db->getValue((new DbQuery())->select('id_order_detail')->from('order_detail')->where("product_attribute_id IN ($ids)"))) {
        throw new RuntimeException("Existing orders reference combinations for {$parent->reference}.");
    }

    $stocks = [];
    foreach ($combinations as $reference => $combination) {
        $stocks[$reference] = (int) StockAvailable::getQuantityAvailableByProduct($parentId, (int) $combination->id, $shopId);
        moveVariantCartLines($combination, (int) $products[$reference]->id, $shopId);
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
        StockAvailable::setQuantity($productId, 0, $stocks[$reference], $shopId, false);
        if ((int) StockAvailable::getQuantityAvailableByProduct($productId, 0, $shopId) !== $stocks[$reference]
            || !Search::indexation(false, $productId)) {
            throw new RuntimeException("Could not restore stock or indexing for {$reference}.");
        }
    }
}
