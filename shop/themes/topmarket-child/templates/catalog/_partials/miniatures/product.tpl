{**
 * TopMarket Child Theme - Product Miniature Override
 * Domitek E-Commerce (1:1 Zgodność z TopMarket.pl + Pełna Dostępność a11y)
 *}
{block name='product_miniature_item'}
<div class="js-product product{if !empty($productClasses)} {$productClasses}{/if}">
  <article class="product-miniature js-product-miniature" data-id-product="{$product.id_product}" data-id-product-attribute="{$product.id_product_attribute}">
    <div class="thumbnail-container">
      <div class="thumbnail-top">
        <div class="tm-card-badges">
          {if $product.has_discount}
            <span class="topmarket-badge-promo">PROMOCJA</span>
          {/if}
          {if $product.quantity > 0}
            <span class="topmarket-badge-shipping">WYSYŁKA DZIŚ</span>
          {else}
            <span class="topmarket-badge-out-of-stock">OBECNIE BRAK NA STANIE</span>
          {/if}
        </div>

        {block name='product_thumbnail'}
          {if $product.cover}
            <a href="{$product.url}" class="thumbnail product-thumbnail" aria-label="{$product.name|escape:'html':'UTF-8'}">
              <picture>
                {if !empty($product.cover.bySize.home_default.sources.avif)}<source srcset="{$product.cover.bySize.home_default.sources.avif}" type="image/avif">{/if}
                {if !empty($product.cover.bySize.home_default.sources.webp)}<source srcset="{$product.cover.bySize.home_default.sources.webp}" type="image/webp">{/if}
                <img
                  src="{$product.cover.bySize.home_default.url}"
                  alt="{if !empty($product.cover.legend)}{$product.cover.legend|escape:'html':'UTF-8'}{elseif !empty($product.name)}{$product.name|escape:'html':'UTF-8'}{else}Produkt{/if}"
                  loading="lazy"
                  data-full-size-image-url="{$product.cover.large.url}"
                  width="{$product.cover.bySize.home_default.width}"
                  height="{$product.cover.bySize.home_default.height}"
                />
              </picture>
            </a>
          {else}
            <a href="{$product.url}" class="thumbnail product-thumbnail" aria-label="{$product.name|escape:'html':'UTF-8'}">
              <picture>
                {if !empty($urls.no_picture_image.bySize.home_default.sources.avif)}<source srcset="{$urls.no_picture_image.bySize.home_default.sources.avif}" type="image/avif">{/if}
                {if !empty($urls.no_picture_image.bySize.home_default.sources.webp)}<source srcset="{$urls.no_picture_image.bySize.home_default.sources.webp}" type="image/webp">{/if}
                <img
                  src="{$urls.no_picture_image.bySize.home_default.url}"
                  alt="{if !empty($product.name)}{$product.name|escape:'html':'UTF-8'}{else}Produkt{/if}"
                  loading="lazy"
                  width="{$urls.no_picture_image.bySize.home_default.width}"
                  height="{$urls.no_picture_image.bySize.home_default.height}"
                />
              </picture>
            </a>
          {/if}
        {/block}

        <div class="highlighted-informations{if !$product.main_variants} no-variants{/if}">
          {block name='quick_view'}
            <a class="quick-view js-quick-view" href="#" data-link-action="quickview" aria-label="{l s='Quick view' d='Shop.Theme.Actions'}">
              <i class="material-icons search" aria-hidden="true">&#xE8B6;</i> {l s='Quick view' d='Shop.Theme.Actions'}
            </a>
          {/block}

          {block name='product_variants'}
            {if $product.main_variants}
              {include file='catalog/_partials/variant-links.tpl' variants=$product.main_variants}
            {/if}
          {/block}
        </div>
      </div>

      <div class="product-description">
        {block name='product_name'}
          {if $page.page_name == 'index'}
            <h3 class="h3 product-title"><a href="{$product.url}">{$product.name|escape:'html':'UTF-8'}</a></h3>
          {else}
            <h2 class="h3 product-title"><a href="{$product.url}">{$product.name|escape:'html':'UTF-8'}</a></h2>
          {/if}
        {/block}

        {block name='product_price_and_shipping'}
          {if $product.show_price}
            <div class="product-price-and-shipping">
              {hook h='displayProductPriceBlock' product=$product type="before_price"}

              <span class="price product-price" aria-label="{l s='Price' d='Shop.Theme.Catalog'}">
                {capture name='custom_price'}{hook h='displayProductPriceBlock' product=$product type='custom_price' hook_origin='products_list'}{/capture}
                {if '' !== $smarty.capture.custom_price}
                  {$smarty.capture.custom_price nofilter}
                {else}
                  {assign var=_price_parts value=','|explode:$product.price}
                  {if $_price_parts|count == 2}
                    <span class="price-int">{$_price_parts[0]}</span><sup class="price-dec">{$_price_parts[1]|regex_replace:'/[\s\x{00a0}]+/u':''}</sup>
                  {else}
                    {$product.price}
                  {/if}
                {/if}
              </span>

              {if $product.has_discount}
                {hook h='displayProductPriceBlock' product=$product type="old_price"}
                <span class="regular-price" aria-label="{l s='Regular price' d='Shop.Theme.Catalog'}">{$product.regular_price}</span>
              {/if}

              {hook h='displayProductPriceBlock' product=$product type="unit_price"}
              {hook h='displayProductPriceBlock' product=$product type="weight"}
            </div>
          {/if}
        {/block}

        {block name='product_reviews'}
          {hook h='displayProductListReviews' product=$product}
        {/block}

        <div class="topmarket-card-btn-container">
          {if $product.quantity > 0}
            <form action="{$urls.pages.cart}" method="post" class="topmarket-cart-form">
              <input type="hidden" name="token" value="{$static_token}">
              <input type="hidden" name="id_product" value="{$product.id_product}">
              <input type="hidden" name="qty" value="1">
              <button class="btn btn-topmarket-cart" data-button-action="add-to-cart" type="submit" aria-label="{l s='Add to cart' d='Shop.Theme.Actions'}: {$product.name|escape:'html':'UTF-8'}">
                <i class="material-icons shopping-cart" aria-hidden="true">&#xE8CC;</i> <span>Do koszyka</span>
              </button>
            </form>
          {else}
            <a href="{$product.url}" class="btn btn-topmarket-view" aria-label="{l s='View product' d='Shop.Theme.Actions'}: {$product.name|escape:'html':'UTF-8'}">
              <i class="material-icons" aria-hidden="true">&#xE8F4;</i> <span>Zobacz produkt</span>
            </a>
          {/if}
        </div>
      </div>

      {include file='catalog/_partials/product-flags.tpl'}
    </div>
  </article>
</div>
{/block}
