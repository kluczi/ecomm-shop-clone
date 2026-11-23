{**
 * TopMarket Child Theme - Checkout Header Override
 * Domitek E-Commerce (Spójne logo Domitek na stronie zamówienia)
 *}
{block name='header_nav'}
  <nav class="header-nav">
    <div class="container">
      <div class="row align-items-center">
        <div class="col-md-6 hidden-sm-down" id="_desktop_logo">
          <a href="{$urls.base_url}" class="logo-link" title="Domitek - Strona główna">
            <img class="logo img-fluid" src="/themes/topmarket-child/assets/img/logo-domitek.svg" alt="Domitek" width="180" height="54">
          </a>
        </div>
        <div class="col-md-6 text-xs-right hidden-sm-down">
          {hook h='displayNav1'}
        </div>
        <div class="hidden-md-up text-sm-center mobile">
          {hook h='displayNav2'}
          <div class="float-xs-left" id="menu-icon">
            <i class="material-icons" aria-hidden="true">&#xE5D2;</i>
          </div>
          <div class="float-xs-right" id="_mobile_cart"></div>
          <div class="float-xs-right" id="_mobile_user_info"></div>
          <div class="top-logo" id="_mobile_logo"></div>
          <div class="clearfix"></div>
        </div>
      </div>
    </div>
  </nav>
{/block}

{block name='header_top'}
  <div class="header-top hidden-md-up">
    <div class="container">
      <div class="row">
        <div class="col-sm-12">
          <div class="row">
            {hook h='displayTop'}
            <div class="clearfix"></div>
          </div>
        </div>
      </div>
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
