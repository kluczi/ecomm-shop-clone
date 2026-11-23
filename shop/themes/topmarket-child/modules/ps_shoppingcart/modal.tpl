{**
 * TopMarket Child Theme - Add-to-Cart Slide-Over Drawer Override (ps_shoppingcart/modal.tpl)
 * Domitek E-Commerce (D1 Issue #30: układ drawer TopMarket + próg darmowej dostawy 2000 zł / 50 kg)
 *}
{assign var="tm_threshold" value=2000}
{assign var="tm_subtotal_amount" value=$cart.subtotals.products.amount|default:0}
{assign var="tm_missing_amount" value=$tm_threshold-$tm_subtotal_amount}
{if $tm_subtotal_amount >= $tm_threshold}
  {assign var="tm_progress_pct" value=100}
{elseif $tm_subtotal_amount <= 0}
  {assign var="tm_progress_pct" value=5}
{else}
  {assign var="tm_progress_pct" value=($tm_subtotal_amount*100/$tm_threshold)|intval}
  {if $tm_progress_pct < 8}{assign var="tm_progress_pct" value=8}{/if}
  {if $tm_progress_pct > 100}{assign var="tm_progress_pct" value=100}{/if}
{/if}

<div id="blockcart-modal" class="modal fade tm-cart-drawer-modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-dialog tm-cart-drawer-dialog" role="document">
    <div class="modal-content tm-cart-drawer-content">
      <div class="modal-header tm-cart-drawer-header">
        <button type="button" class="close tm-drawer-close" data-dismiss="modal" aria-label="{l s='Close' d='Shop.Theme.Global'}">
          <span aria-hidden="true">&times;</span>
        </button>
        <h4 class="modal-title tm-drawer-title" id="myModalLabel">Twój koszyk</h4>
        <p class="tm-drawer-added-note">
          <i class="material-icons rtl-no-flip" aria-hidden="true">&#xE876;</i>
          <span>Produkt dodany do koszyka ({$cart.products_count} {if $cart.products_count == 1}produkt{elseif $cart.products_count < 5}produkty{else}produktów{/if})</span>
        </p>
      </div>

      <div class="modal-body tm-cart-drawer-body">
        <!-- Pasek postępu darmowej dostawy od 2000 zł -->
        <div class="tm-drawer-shipping-progress">
          {if $tm_missing_amount <= 0}
            <p class="tm-shipping-msg is-free">Otrzymujesz darmową dostawę! <span class="tm-shipping-weight-note">(maks. waga zamówienia 50 kg)</span></p>
          {else}
            <p class="tm-shipping-msg">Do darmowej dostawy (od 2000 zł) brakuje Ci: <strong>{$tm_missing_amount|string_format:"%.2f"|replace:'.':','} zł</strong></p>
          {/if}
          <div class="tm-progress-track">
            <div class="tm-progress-fill" style="width: {$tm_progress_pct}%;"></div>
            <div class="tm-progress-truck" style="left: calc({$tm_progress_pct}% - 16px);">
              <i class="material-icons" aria-hidden="true">&#xE558;</i>
            </div>
          </div>
        </div>

        <!-- Lista produktów w koszyku / ostatnio dodany -->
        <div class="tm-drawer-items">
          {if !empty($cart.products)}
            {foreach from=$cart.products item=cart_item}
              <div class="tm-drawer-item">
                <div class="tm-drawer-item-img">
                  {if $cart_item.cover && $cart_item.cover.bySize.small_default.url}
                    <img src="{$cart_item.cover.bySize.small_default.url}" alt="{$cart_item.name}" loading="lazy" width="70" height="70">
                  {elseif $product.default_image}
                    <img src="{$product.default_image.medium.url}" alt="{$cart_item.name}" loading="lazy" width="70" height="70">
                  {else}
                    <img src="{$urls.no_picture_image.bySize.small_default.url}" alt="{$cart_item.name}" loading="lazy" width="70" height="70">
                  {/if}
                </div>
                <div class="tm-drawer-item-info">
                  <div class="tm-drawer-item-name">{$cart_item.name}</div>
                  {if !empty($cart_item.attributes)}
                    <div class="tm-drawer-item-attrs">{$cart_item.attributes}</div>
                  {/if}
                  <div class="tm-drawer-item-meta">
                    <span class="tm-drawer-item-qty">Ilość: <strong>{$cart_item.cart_quantity}</strong></span>
                    <span class="tm-drawer-item-price">{$cart_item.total}</span>
                  </div>
                </div>
              </div>
            {/foreach}
          {else}
            <div class="tm-drawer-item">
              <div class="tm-drawer-item-img">
                {if $product.default_image}
                  <img src="{$product.default_image.medium.url}" data-full-size-image-url="{$product.default_image.large.url}" title="{$product.default_image.legend}" alt="{$product.name}" loading="lazy" class="product-image" width="70" height="70">
                {else}
                  <img src="{$urls.no_picture_image.bySize.medium_default.url}" alt="{$product.name}" loading="lazy" class="product-image" width="70" height="70">
                {/if}
              </div>
              <div class="tm-drawer-item-info">
                <h6 class="tm-drawer-item-name product-name">{$product.name}</h6>
                <div class="tm-drawer-item-meta">
                  <span class="tm-drawer-item-qty product-quantity">Ilość: <strong>{$product.cart_quantity}</strong></span>
                  <span class="tm-drawer-item-price product-price">{$product.price}</span>
                </div>
              </div>
            </div>
          {/if}
        </div>

        {hook h='displayCartModalContent' product=$product}
      </div>

      <div class="modal-footer tm-cart-drawer-footer">
        <div class="tm-drawer-summary-rows">
          <div class="tm-drawer-summary-row">
            <span>Wartość zamówienia:</span>
            <span class="subtotal value">{$cart.subtotals.products.value}</span>
          </div>
          {if $cart.subtotals.shipping.value}
            <div class="tm-drawer-summary-row">
              <span>Dostawa:</span>
              <span class="shipping value {if $cart.subtotals.shipping.amount == 0}is-free{/if}">
                {if $cart.subtotals.shipping.amount == 0}Za darmo!{else}{$cart.subtotals.shipping.value}{/if}
              </span>
            </div>
          {/if}
          <div class="tm-drawer-summary-row is-total">
            <span>W SUMIE:</span>
            <span class="tm-drawer-total-val value">{$cart.totals.total.value}</span>
          </div>
        </div>

        <div class="cart-content-btn tm-drawer-actions">
          <a href="{$cart_url}" class="btn btn-primary tm-drawer-cta">
            <i class="material-icons rtl-no-flip" aria-hidden="true">&#xE8CC;</i>
            <span>Przejdź do koszyka</span>
          </a>
          <button type="button" class="btn tm-drawer-continue" data-dismiss="modal">Kontynuuj zakupy</button>
        </div>

        {hook h='displayCartModalFooter' product=$product}
      </div>
    </div>
  </div>
</div>
