{**
 * TopMarket Child Theme - Header Template
 * Domitek E-Commerce (Układ 1:1 TopMarket.pl dla sklepu Domitek)
 *}
{block name='header_banner'}
  <div class="header-banner">
    {hook h='displayBanner'}
  </div>
{/block}

{block name='header_nav'}
  <nav class="header-nav topbar-light" aria-label="Nawigacja mobilna">
    <div class="container">
      <div class="row align-items-center">
        <div class="hidden-md-up text-sm-center mobile-header-row">
          <div class="top-logo" id="_mobile_logo"></div>
          <div class="mobile-actions-wrapper">
            <button type="button" id="mobile-search-toggle" class="mobile-icon-btn" aria-label="Otwórz wyszukiwarkę" aria-expanded="false" aria-controls="mobile_search_bar_panel">
              <i class="material-icons" aria-hidden="true">&#xE8B6;</i>
            </button>
            <div id="_mobile_user_info"></div>
            <div id="_mobile_cart"></div>
            <button type="button" id="menu-icon" class="mobile-icon-btn" aria-label="Menu nawigacji" aria-expanded="false" aria-controls="mobile_top_menu_wrapper">
              <i class="material-icons" aria-hidden="true">&#xE5D2;</i>
            </button>
          </div>
        </div>
      </div>
    </div>
    <div id="mobile_search_bar_panel" class="hidden-md-up mobile-search-panel" style="display:none;">
      <div class="container">
        {hook h='displaySearch'}
      </div>
    </div>
  </nav>
{/block}

{block name='header_top'}
  <div class="header-top">
    <div class="container">
      <div class="row align-items-center header-main-row hidden-sm-down">
        <!-- Logo Domitek w geometrycznym stylu TopMarket -->
        <div class="col-md-3 header-col-logo" id="_desktop_logo">
          <a href="{$urls.base_url}" class="logo-link" title="Domitek - Strona główna">
            <img class="logo img-fluid" src="/themes/topmarket-child/assets/img/logo-domitek.svg" alt="Domitek" width="180" height="54">
          </a>
        </div>

        <!-- Środkowa wyszukiwarka Czego szukasz? -->
        <div class="col-md-6 header-col-search header-search-center">
          {hook h='displaySearch'}
        </div>

        <!-- Przyciski akcji po prawej: Zaloguj się & Koszyk -->
        <div class="col-md-3 header-col-actions header-actions-right">
          {hook h='displayNav2'}
        </div>
      </div>

      <!-- Pasek kategorii (PROMOCJE na czerwono + podkategorie + BESTSELLERY po prawej) -->
      <div class="row header-menu-row hidden-sm-down">
        <div class="col-md-12 position-static">
          {hook h='displayTop'}
        </div>
      </div>

      <!-- Mobilny panel wysuwanego menu -->
      <div id="mobile_top_menu_wrapper" class="row hidden-md-up" style="display:none;">
        <div class="js-top-menu mobile" id="_mobile_top_menu"></div>
        <div class="js-top-menu-bottom">
          <div id="_mobile_currency_selector"></div>
          <div id="_mobile_language_selector"></div>
          <div id="_mobile_contact_link"></div>
        </div>
      </div>
    </div>
  </div>
  {hook h='displayNavFullWidth'}
{/block}
