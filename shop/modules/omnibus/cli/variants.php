<?php

if (!defined('_PS_VERSION_')) {
    exit;
}

function variantAttributes(string $groupName, array $names, int $languageId): array
{
    $db = Db::getInstance();
    $groupId = (int) $db->getValue(
        (new DbQuery())->select('id_attribute_group')->from('attribute_group_lang')
            ->where('id_lang = ' . $languageId . " AND name = '" . pSQL($groupName) . "'")
    );
    $languages = Language::getIDs(false);
    if (!$groupId) {
        $group = new AttributeGroup();
        $group->name = array_fill_keys($languages, $groupName);
        $group->public_name = $group->name;
        $group->group_type = 'select';
        if (!$group->add()) {
            throw new RuntimeException("Could not create the {$groupName} attribute group.");
        }
        $groupId = (int) $group->id;
    }

    $ids = [];
    foreach ($names as $name) {
        $id = (int) $db->getValue(
            (new DbQuery())->select('a.id_attribute')->from('attribute', 'a')
                ->innerJoin('attribute_lang', 'al', 'al.id_attribute = a.id_attribute')
                ->where('a.id_attribute_group = ' . $groupId . ' AND al.id_lang = ' . $languageId
                    . " AND al.name = '" . pSQL($name) . "'")
        );
        if (!$id) {
            $attribute = new ProductAttribute();
            $attribute->id_attribute_group = $groupId;
            $attribute->name = array_fill_keys($languages, $name);
            if (!$attribute->add()) {
                throw new RuntimeException("Could not create the {$name} attribute.");
            }
            $id = (int) $attribute->id;
        }
        $ids[$name] = $id;
    }

    return $ids;
}

function attachVariantImage(Combination $combination, Product $source, array &$copiedImages): void
{
    if ($combination->getWsImages() || !($cover = Image::getCover((int) $source->id))) {
        return;
    }

    $image = new Image((int) $cover['id_image']);
    $original = _PS_PRODUCT_IMG_DIR_ . $image->getExistingImgPath() . '.jpg';
    if (!is_file($original)) {
        return;
    }

    $imageId = (int) $image->id;
    if ((int) $source->id !== (int) $combination->id_product) {
        $copy = new Image();
        $copy->id_product = (int) $combination->id_product;
        $copy->legend = $image->legend;
        if (!$copy->add()) {
            throw new RuntimeException("Could not create an image for {$source->reference}.");
        }
        $copiedImages[] = $copy;
        $destination = $copy->getPathForCreation();
        if (!$destination || !copy($original, $destination . '.jpg')) {
            throw new RuntimeException("Could not copy the image for {$source->reference}.");
        }
        foreach (ImageType::getImagesTypes('products') as $type) {
            $thumbnail = $destination . '-' . $type['name'] . '.jpg';
            if (!ImageManager::resize($original, $thumbnail, (int) $type['width'], (int) $type['height'])) {
                throw new RuntimeException("Could not create the thumbnail for {$source->reference}.");
            }
        }
        $imageId = (int) $copy->id;
    }

    if (!$combination->setImages([$imageId])) {
        throw new RuntimeException("Could not attach the image for {$source->reference}.");
    }
}

function seedVariantGroup(array $group, array $products, int $shopId, int $languageId, array &$copiedImages): void
{
    $options = $group['options'];
    $parent = $products[reset($options)[0]];
    $parentId = (int) $parent->id;
    $existing = array_map(
        static fn ($row) => (new Combination((int) $row['id_product_attribute']))->reference,
        Product::getProductAttributesIds($parentId, true)
    );
    if (array_diff($existing, array_column($options, 0))) {
        throw new RuntimeException("{$parent->reference} already has other variants.");
    }

    $initialStocks = [];
    foreach ($options as [$reference]) {
        $initialStocks[$reference] = (int) StockAvailable::getQuantityAvailableByProduct(
            (int) $products[$reference]->id,
            0,
            $shopId
        );
    }
    $stockLimit = array_sum($initialStocks) > 10 ? intdiv(10, count($options)) : 10;

    $description = '<ul>';
    foreach ($options as $label => [, $details]) {
        $description .= '<li>' . htmlspecialchars($label . ' — ' . $details, ENT_QUOTES, 'UTF-8') . '</li>';
    }
    $description .= '</ul>';
    if ($parent->name !== $group['name'] || $parent->description !== $description) {
        $parent->name = $group['name'];
        $parent->link_rewrite = Tools::str2url($group['name']);
        $parent->description = $description;
        if (!$parent->update()) {
            throw new RuntimeException("Could not update the product page for {$parent->reference}.");
        }
    }

    $attributes = variantAttributes($group['attribute'], array_keys($options), $languageId);
    foreach ($options as $label => [$reference]) {
        $source = $products[$reference];
        $sourceId = (int) $source->id;
        $isDefault = $sourceId === $parentId;
        if (!$isDefault && ($source->hasAttributes() || (int) $source->id_tax_rules_group !== (int) $parent->id_tax_rules_group)) {
            throw new RuntimeException("{$reference} needs to be a simple product with the same tax rule as {$parent->reference}.");
        }

        $id = (int) Combination::getIdByReference($parentId, $reference);
        $combination = new Combination($id ?: null, null, $shopId);
        $price = round((float) $source->price - (float) $parent->price, 6);
        $weight = round((float) $source->weight - (float) $parent->weight, 6);
        if (!$id) {
            $quantity = min($stockLimit, $initialStocks[$reference]);
            $combination->id_product = $parentId;
            $combination->reference = $reference;
            $combination->default_on = $isDefault ? true : null;
            $combination->price = $price;
            $combination->weight = $weight;
            if (!$combination->add() || !$combination->setAttributes([$attributes[$label]])) {
                throw new RuntimeException("Could not create the {$label} variant for {$parent->reference}.");
            }
            StockAvailable::setQuantity($parentId, (int) $combination->id, $quantity, $shopId, false);
            if ((int) StockAvailable::getQuantityAvailableByProduct($parentId, (int) $combination->id, $shopId) !== $quantity) {
                throw new RuntimeException("Could not set stock for {$reference}.");
            }
        } elseif ((float) $combination->price !== $price || (float) $combination->weight !== $weight) {
            $combination->price = $price;
            $combination->weight = $weight;
            if (!$combination->update()) {
                throw new RuntimeException("Could not update the {$label} variant for {$parent->reference}.");
            }
        }

        attachVariantImage($combination, $source, $copiedImages);
        if (!$isDefault && ($source->active || $source->redirect_type !== '301-product' || (int) $source->id_type_redirected !== $parentId)) {
            $source->active = false;
            $source->available_for_order = false;
            $source->visibility = 'none';
            $source->redirect_type = '301-product';
            $source->id_type_redirected = $parentId;
            if (!$source->update()) {
                throw new RuntimeException("Could not redirect {$reference} to {$parent->reference}.");
            }
            Search::removeProductsSearchIndex([$sourceId]);
        }
    }

    Search::indexation(false, $parentId);
}
