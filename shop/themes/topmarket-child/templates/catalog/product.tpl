{**
 * TopMarket Child Theme - Product Page Template (1:1 with TopMarket.pl)
 * Domitek E-Commerce
 *}
{extends file='parent:catalog/product.tpl'}

{block name='page_content_container'}
  <section class="page-content" id="content">
    {block name='page_content'}
      {include file='catalog/_partials/product-flags.tpl'}

      <div class="topmarket-product-gallery-wrapper">
        {block name='product_cover_thumbnails'}
          {include file='catalog/_partials/product-cover-thumbnails.tpl'}
        {/block}
      </div>
    {/block}
  </section>
{/block}

{block name='page_header_container'}
  <div class="topmarket-product-header">
    <h1 class="topmarket-product-title">{block name='page_title'}{$product.name}{/block}</h1>

    <!-- 3 Plakietki korzyści TopMarket pod tytułem -->
    <div class="topmarket-product-reassurance-list">
      {if $product.quantity > 0}
        <div class="topmarket-reassurance-item in-stock">
          <i class="material-icons check-icon">&#xE876;</i> <span>Dostępny</span>
        </div>
      {else}
        <div class="topmarket-reassurance-item out-of-stock">
          <i class="material-icons error-icon">&#xE000;</i> <span>Obecnie brak na stanie</span>
        </div>
      {/if}
      <div class="topmarket-reassurance-item free-shipping">
        <i class="material-icons truck-icon">&#xE558;</i> <span>Darmowa dostawa od 2000 zł (maks. waga zamówienia 50 kg)</span>
      </div>
      <div class="topmarket-reassurance-item installments">
        <i class="material-icons installment-icon">&#xE8B0;</i> <span>Rata 0% już od: {($product.price_amount / 5)|string_format:"%.2f"} zł</span>
      </div>
    </div>
  </div>
{/block}

{block name='product_prices'}
  <div class="topmarket-product-price-block">
    <div class="topmarket-main-price">{$product.price}</div>
    {if $product.has_discount}
      <div class="topmarket-regular-price">{$product.regular_price}</div>
      <div class="topmarket-omnibus-price">Cena z ostatnich 30 dni: {$product.regular_price}</div>
    {/if}
  </div>
{/block}

{block name='product_buy'}
  <form action="{$urls.pages.cart}" method="post" id="add-to-cart-or-refresh">
    <input type="hidden" name="token" value="{$static_token}">
    <input type="hidden" name="id_product" value="{$product.id}" id="product_page_product_id">
    <input type="hidden" name="id_customization" value="{$product.id_customization}" id="product_customization_id">

    {block name='product_variants'}
      {include file='catalog/_partials/product-variants.tpl'}
    {/block}

    <div class="topmarket-add-to-cart-row">
      <div class="topmarket-qty-stepper">
        <button type="button" class="qty-btn qty-down" aria-label="Zmniejsz ilość">-</button>
        <input
          type="number"
          name="qty"
          id="quantity_wanted"
          aria-label="{l s='Quantity' d='Shop.Theme.Actions'}"
          value="{if $product.quantity_wanted}{$product.quantity_wanted}{else}1{/if}"
          min="{$product.minimal_quantity}"
          class="topmarket-qty-input"
        >
        <button type="button" class="qty-btn qty-up" aria-label="Zwiększ ilość">+</button>
      </div>

      <button
        class="btn btn-primary topmarket-btn-add-cart add-to-cart"
        data-button-action="add-to-cart"
        type="submit"
        {if !$product.add_to_cart_url}disabled{/if}
      >
        <i class="material-icons">&#xE8CC;</i>
        <span>{if $product.quantity > 0}Do koszyka{else}Brak na stanie{/if}</span>
      </button>

      <button type="button" class="btn topmarket-btn-wishlist" title="Dodaj do listy życzeń" aria-label="Dodaj do listy życzeń">
        <i class="material-icons">&#xE87E;</i>
      </button>
    </div>

    <!-- Pasek PayPo w stylu TopMarket -->
    <div class="topmarket-paypo-banner">
      <span class="paypo-logo">PayPo</span>
      <span class="paypo-divider">|</span>
      <span class="paypo-text">Kup teraz i zapłać za 30 dni</span>
      <a href="https://paypo.pl" target="_blank" rel="noopener" class="paypo-link">SPRAWDŹ</a>
    </div>

    {hook h='displayProductActions' product=$product}
  </form>

  <!-- Pływający dolny pasek zakupu (Sticky Bottom Buy Bar jak w TopMarket) -->
  <div id="topmarket-sticky-buy-bar" class="topmarket-sticky-bar">
    <div class="container d-flex align-items-center justify-content-between">
      <div class="sticky-product-info d-flex align-items-center">
        {if $product.default_image}
          <img src="{$product.default_image.bySize.small_default.url}" alt="{$product.name}" class="sticky-thumb" width="48" height="48">
        {/if}
        <span class="sticky-title">{$product.name|truncate:45:'...'}</span>
        <span class="sticky-price">{$product.price}</span>
      </div>
      <div class="sticky-buy-actions d-flex align-items-center">
        <div class="sticky-qty-stepper">
          <button type="button" class="qty-btn sticky-qty-down" aria-label="Zmniejsz ilość">-</button>
          <input type="number" id="sticky_quantity_wanted" value="1" min="1" class="sticky-qty-input" aria-label="Ilość w koszyku">
          <button type="button" class="qty-btn sticky-qty-up" aria-label="Zwiększ ilość">+</button>
        </div>
        <button type="button" class="btn btn-primary topmarket-btn-sticky-cart" onclick="document.querySelector('#add-to-cart-or-refresh button.add-to-cart').click();">
          <span>Dodaj do koszyka</span>
        </button>
      </div>
    </div>
  </div>
{/block}

{block name='product_accessories'}
  {if $accessories}
    <section class="product-accessories topmarket-related-products">
      <div class="container">
        <h2 class="section-title-divider"><span>Sprawdź podobne produkty</span></h2>
        <div class="products row">
          {foreach from=$accessories item="product_accessory" key="position"}
            {block name='product_miniature'}
              {include file='catalog/_partials/miniatures/product.tpl' product=$product_accessory position=$position productClasses="col-xs-12 col-sm-6 col-lg-3"}
            {/block}
          {/foreach}
        </div>
      </div>
    </section>
  {/if}
{/block}
