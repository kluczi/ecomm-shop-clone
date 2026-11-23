{**
 * TopMarket Child Theme - Product Cover Thumbnails Override
 * Domitek E-Commerce (1:1 a11y: atrybuty alt dla zdjęć okładkowych)
 *}
<div class="images-container js-images-container">
  {block name='product_cover'}
    <div class="product-cover">
      {if $product.quantity > 0}
        <span class="topmarket-badge-shipping pdp-shipping-badge">WYSYŁKA DZIŚ</span>
      {/if}
      {if $product.default_image}
        <picture>
          {if !empty($product.default_image.bySize.large_default.sources.avif)}<source srcset="{$product.default_image.bySize.large_default.sources.avif}" type="image/avif">{/if}
          {if !empty($product.default_image.bySize.large_default.sources.webp)}<source srcset="{$product.default_image.bySize.large_default.sources.webp}" type="image/webp">{/if}
          <img
            class="js-qv-product-cover img-fluid"
            src="{$product.default_image.bySize.large_default.url}"
            {if !empty($product.default_image.legend)}
              alt="{$product.default_image.legend}"
              title="{$product.default_image.legend}"
            {else}
              alt="{$product.name}"
              title="{$product.name}"
            {/if}
            loading="lazy"
            width="{$product.default_image.bySize.large_default.width}"
            height="{$product.default_image.bySize.large_default.height}"
          >
        </picture>
        <button type="button" class="topmarket-cover-arrow cover-prev hidden-sm-down" aria-label="Poprzednie zdjęcie">
          <i class="material-icons">&#xE5CB;</i>
        </button>
        <button type="button" class="topmarket-cover-arrow cover-next hidden-sm-down" aria-label="Następne zdjęcie">
          <i class="material-icons">&#xE5CC;</i>
        </button>
        <div class="topmarket-zoom-icon-box" data-toggle="modal" data-target="#product-modal" title="Powiększ zdjęcie">
          <i class="material-icons">&#xE8FF;</i>
        </div>
      {else}
        <picture>
          {if !empty($urls.no_picture_image.bySize.large_default.sources.avif)}<source srcset="{$urls.no_picture_image.bySize.large_default.sources.avif}" type="image/avif">{/if}
          {if !empty($urls.no_picture_image.bySize.large_default.sources.webp)}<source srcset="{$urls.no_picture_image.bySize.large_default.sources.webp}" type="image/webp">{/if}
          <img
            class="img-fluid"
            src="{$urls.no_picture_image.bySize.large_default.url}"
            alt="{$product.name}"
            title="{$product.name}"
            loading="lazy"
            width="{$urls.no_picture_image.bySize.large_default.width}"
            height="{$urls.no_picture_image.bySize.large_default.height}"
          >
        </picture>
      {/if}
    </div>
  {/block}

  {block name='product_images'}
    <div class="js-qv-mask mask">
      <ul class="product-images js-qv-product-images">
        {foreach from=$product.images item=image}
          <li class="thumb-container js-thumb-container">
            <picture>
              {if !empty($image.bySize.small_default.sources.avif)}<source srcset="{$image.bySize.small_default.sources.avif}" type="image/avif">{/if}
              {if !empty($image.bySize.small_default.sources.webp)}<source srcset="{$image.bySize.small_default.sources.webp}" type="image/webp">{/if}
              <img
                class="thumb js-thumb {if $image.id_image == $product.default_image.id_image} selected js-thumb-selected {/if}"
                data-image-medium-src="{$image.bySize.medium_default.url}"
                {if !empty($image.bySize.medium_default.sources)}data-image-medium-sources="{$image.bySize.medium_default.sources|@json_encode}"{/if}
                data-image-large-src="{$image.bySize.large_default.url}"
                {if !empty($image.bySize.large_default.sources)}data-image-large-sources="{$image.bySize.large_default.sources|@json_encode}"{/if}
                src="{$image.bySize.small_default.url}"
                {if !empty($image.legend)}
                  alt="{$image.legend}"
                  title="{$image.legend}"
                {else}
                  alt="{$product.name}"
                  title="{$product.name}"
                {/if}
                loading="lazy"
                width="{$product.default_image.bySize.small_default.width}"
                height="{$product.default_image.bySize.small_default.height}"
              >
            </picture>
          </li>
        {/foreach}
      </ul>
    </div>
  {/block}
{hook h='displayAfterProductThumbs' product=$product}
</div>
