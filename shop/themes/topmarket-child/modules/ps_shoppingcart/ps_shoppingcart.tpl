{**
 * TopMarket Child Theme - Shopping Cart Template Override
 * Domitek E-Commerce (1:1 Układ TopMarket.pl: duża ikona torby 32px z koralowym badge #d06e6a, podpis Koszyk 12px)
 *}
<div id="_desktop_cart" class="header-cart-btn-wrapper">
  <div class="blockcart cart-preview header-btn-inner {if $cart.products_count > 0}active{else}inactive{/if}" data-refresh-url="{$refresh_url}">
    <div class="header">
      <a rel="nofollow" aria-label="Koszyk, liczba produktów: {$cart.products_count}" href="{$cart_url}" class="header-action-btn cart-link">
        <div class="cart-icon-container">
          <svg class="header-btn-icon header-bag-svg" width="26" height="26" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false">
            <path d="M18 6h-2c0-2.21-1.79-4-4-4S8 3.79 8 6H6c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zm-6-2c1.1 0 2 .9 2 2h-4c0-1.1.9-2 2-2z"/>
          </svg>
          <span class="cart-products-count-badge">{$cart.products_count}</span>
        </div>
        <span class="header-btn-title">Koszyk</span>
      </a>
    </div>
  </div>
</div>
