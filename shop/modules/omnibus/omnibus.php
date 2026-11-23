<?php

if (!defined('_PS_VERSION_')) {
    exit;
}

class Omnibus extends Module
{
    private const HISTORY = 'omnibus_price_history';
    private const PROMOTIONS = 'omnibus_promotion';

    public function __construct()
    {
        $this->name = 'omnibus';
        $this->tab = 'pricing_promotion';
        $this->version = '1.0.0';
        $this->need_instance = 0;
        $this->ps_versions_compliancy = ['min' => '8.2.0', 'max' => _PS_VERSION_];
        parent::__construct();

        $this->displayName = 'Omnibus';
        $this->description = 'Wyświetla najniższą cenę z 30 dni przed obniżką.';
    }

    public function install()
    {
        $db = Db::getInstance();
        $history = _DB_PREFIX_ . self::HISTORY;
        $promotions = _DB_PREFIX_ . self::PROMOTIONS;

        return $db->execute("CREATE TABLE IF NOT EXISTS `$history` (
                id_price_history INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                id_shop INT UNSIGNED NOT NULL,
                id_product INT UNSIGNED NOT NULL,
                id_currency INT UNSIGNED NOT NULL,
                price_gross DECIMAL(20,6) UNSIGNED NOT NULL,
                recorded_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                KEY product_prices (id_shop, id_product, id_currency, recorded_at, id_price_history)
            ) ENGINE=InnoDB")
            && $db->execute("CREATE TABLE IF NOT EXISTS `$promotions` (
                id_shop INT UNSIGNED NOT NULL,
                id_product INT UNSIGNED NOT NULL,
                id_specific_price INT UNSIGNED NOT NULL,
                id_currency INT UNSIGNED NOT NULL,
                lowest_price DECIMAL(20,6) UNSIGNED NOT NULL,
                started_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                PRIMARY KEY (id_shop, id_product)
            ) ENGINE=InnoDB")
            && parent::install()
            && $this->registerHook([
                'actionObjectProductAddAfter',
                'actionObjectProductUpdateAfter',
                'displayProductPriceBlock',
            ])
            && $this->registerVariantHooks();
    }

    public function registerVariantHooks(): bool
    {
        foreach (['actionPresentProductListing', 'actionFrontControllerInitAfter', 'actionUpdateQuantity'] as $hook) {
            if (!$this->isRegisteredInHook($hook) && !$this->registerHook($hook)) {
                return false;
            }
        }

        return true;
    }

    public function hookActionPresentProductListing(array $params): void
    {
        static $listingNames = null;
        if ($listingNames === null) {
            $listingNames = [];
            $catalog = require __DIR__ . '/catalog.php';
            foreach ($catalog['variant_groups'] as $group) {
                $options = $group['options'];
                $listingNames[reset($options)[0]] = $group['listing_name'];
            }
        }

        $product = $params['presentedProduct'];
        $reference = (string) ($product['reference'] ?? '');
        $productId = (int) $product['id_product'];
        if (isset($listingNames[$reference])) {
            $target = $productId;
        } elseif (($product['redirect_type'] ?? '') === '301-product' && empty($product['available_for_order'])) {
            $target = (int) ($product['id_type_redirected'] ?? 0);
        } else {
            return;
        }

        $variant = (int) Combination::getIdByReference($target, $reference);
        if (!$variant) {
            return;
        }
        if (isset($listingNames[$reference])) {
            $product->offsetSet('name', $listingNames[$reference], true);
        }
        $url = $this->context->link->getProductLink($target, idProductAttribute: $variant);
        $product->offsetSet('url', $url, true);
        $product->offsetSet('link', $url, true);
    }

    public function hookActionFrontControllerInitAfter(array $params): void
    {
        if (!$params['controller'] instanceof ProductController) {
            return;
        }

        $source = new Product((int) Tools::getValue('id_product'));
        $target = (int) $source->id_type_redirected;
        if (!$target || $target === (int) $source->id || $source->available_for_order || $source->redirect_type !== '301-product') {
            return;
        }
        $variant = (int) Combination::getIdByReference($target, $source->reference);
        if (!$variant) {
            return;
        }

        $extra = Tools::getValue('ajax') && Tools::getValue('action') === 'quickview'
            ? ['ajax' => 1, 'action' => 'quickview']
            : [];
        Tools::redirect($this->context->link->getProductLink($target, idProductAttribute: $variant, extraParams: $extra));
    }

    public function hookActionUpdateQuantity(array $params): void
    {
        $variant = (int) ($params['id_product_attribute'] ?? 0);
        if (!$variant) {
            return;
        }

        $combination = new Combination($variant);
        $sourceId = (int) Product::getIdByReference($combination->reference);
        $parentId = (int) $params['id_product'];
        if (!$sourceId || $sourceId === $parentId) {
            return;
        }

        $shopId = (int) (($params['id_shop'] ?? null) ?: $this->context->shop->id);
        $source = new Product($sourceId, false, null, $shopId);
        if (!$source->available_for_order && $source->redirect_type === '301-product' && (int) $source->id_type_redirected === $parentId) {
            StockAvailable::setQuantity($sourceId, 0, (int) $params['quantity'], $shopId, false);
        }
    }

    public function hookActionObjectProductAddAfter($params)
    {
        $this->recordPrice($params['object']);
    }

    public function hookActionObjectProductUpdateAfter($params)
    {
        $this->recordPrice($params['object']);
    }

    public function recordPrice(Product $product, ?float $reduction = null): void
    {
        static $discounts = null;
        if ($discounts === null) {
            $catalog = require __DIR__ . '/catalog.php';
            $discounts = $catalog['discounts'];
        }

        if (!$product->active || !$product->show_price || !isset($discounts[$product->reference])) {
            return;
        }

        if ($reduction === null) {
            $promotion = $this->getPromotion((int) $product->id);
            $priceRule = $promotion ? new SpecificPrice((int) $promotion['id_specific_price']) : null;
            $reduction = $priceRule && $priceRule->reduction_type === 'percentage' ? (float) $priceRule->reduction : 0.0;
        }

        $shop = (int) $this->context->shop->id;
        $currency = (int) Configuration::get('PS_CURRENCY_DEFAULT', null, null, $shop);
        $price = (float) $product->price;
        if (Configuration::get('PS_TAX', null, null, $shop)) {
            $address = new Address();
            $address->id_country = (int) Configuration::get('PS_COUNTRY_DEFAULT', null, null, $shop);
            $manager = TaxManagerFactory::getManager($address, (int) $product->id_tax_rules_group);
            $price = $manager->getTaxCalculator()->addTaxes($price);
        }

        $db = Db::getInstance();
        $query = (new DbQuery())
            ->select('price_gross')->from(self::HISTORY)
            ->where($this->productCondition((int) $product->id) . ' AND id_currency = ' . $currency)
            ->orderBy('recorded_at DESC, id_price_history DESC');
        $lastPrice = $db->getValue($query, false);
        $price = round($price * (1 - $reduction), 6);
        if ($lastPrice !== false && (float) $lastPrice === $price) {
            return;
        }

        if (!$db->insert(self::HISTORY, [
            'id_shop' => $shop,
            'id_product' => (int) $product->id,
            'id_currency' => $currency,
            'price_gross' => $price,
        ])) {
            throw new RuntimeException('Could not record price for ' . $product->reference);
        }
    }

    public function getPromotion(int $productId): ?array
    {
        $query = (new DbQuery())->select('*')->from(self::PROMOTIONS)
            ->where($this->productCondition($productId));

        return Db::getInstance()->getRow($query, false) ?: null;
    }

    public function savePromotion(Product $product, SpecificPrice $specificPrice): void
    {
        $shop = (int) $this->context->shop->id;
        $currency = (int) Configuration::get('PS_CURRENCY_DEFAULT', null, null, $shop);
        $condition = $this->productCondition((int) $product->id) . ' AND id_currency = ' . $currency;
        $cutoff = 'CURRENT_TIMESTAMP(6) - INTERVAL 30 DAY';
        $db = Db::getInstance();
        $inWindow = (new DbQuery())->select('MIN(price_gross)')->from(self::HISTORY)
            ->where($condition . ' AND recorded_at > ' . $cutoff);
        $beforeWindow = (new DbQuery())->select('price_gross')->from(self::HISTORY)
            ->where($condition . ' AND recorded_at <= ' . $cutoff)
            ->orderBy('recorded_at DESC, id_price_history DESC');
        $observed = $db->getValue($inWindow, false);
        $carriedOver = $db->getValue($beforeWindow, false);
        $prices = array_filter([$observed, $carriedOver], 'is_numeric');
        if (!$prices || !$db->insert(self::PROMOTIONS, [
            'id_shop' => $shop,
            'id_product' => (int) $product->id,
            'id_specific_price' => (int) $specificPrice->id,
            'id_currency' => $currency,
            'lowest_price' => min($prices),
            'started_at' => ['type' => 'sql', 'value' => 'CURRENT_TIMESTAMP(6)'],
        ], false, true, Db::ON_DUPLICATE_KEY)) {
            throw new RuntimeException('Could not save the reference price for ' . $product->reference);
        }
    }

    public function hookDisplayProductPriceBlock($params)
    {
        if (($params['type'] ?? '') !== 'old_price') {
            return '';
        }

        $product = $params['product'];
        $specificPriceId = (int) ($product['specific_prices']['id_specific_price'] ?? 0);
        if (!$specificPriceId) {
            return '';
        }

        $promotion = $this->getPromotion((int) $product['id_product']);
        if (!$promotion || (int) $promotion['id_specific_price'] !== $specificPriceId) {
            return '';
        }

        $this->context->smarty->assign('omnibus_price', $this->context->getCurrentLocale()->formatPrice(
            (float) $promotion['lowest_price'],
            Currency::getIsoCodeById((int) $promotion['id_currency'])
        ));

        return $this->display(__FILE__, 'views/templates/hook/lowest-price.tpl');
    }

    private function productCondition(int $productId): string
    {
        return 'id_shop = ' . (int) $this->context->shop->id . ' AND id_product = ' . $productId;
    }
}
