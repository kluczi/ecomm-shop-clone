{**
 * TopMarket Child Theme - Customer Sign In Override
 * Domitek E-Commerce (1:1 Układ pionowy: ikona użytkownika na górze, podpis na dole)
 *}
<div id="_desktop_user_info" class="header-user-btn-wrapper">
  <div class="user-info header-btn-inner">
    {if $logged}
      <a class="header-action-btn account-link" href="{$urls.pages.my_account}" title="Moje konto" rel="nofollow">
        <i class="material-icons header-btn-icon" aria-hidden="true">&#xE853;</i>
        <span class="header-btn-title">Moje konto</span>
      </a>
      <a class="header-logout-link hidden-sm-down" href="{$urls.actions.logout}" title="Wyloguj się" rel="nofollow">
        (Wyloguj)
      </a>
    {else}
      <a class="header-action-btn signin-link" href="{$urls.pages.authentication}?back={$urls.current_url|urlencode}" title="Zaloguj się do swojego konta" rel="nofollow">
        <i class="material-icons header-btn-icon" aria-hidden="true">&#xE853;</i>
        <span class="header-btn-title">Zaloguj się</span>
      </a>
    {/if}
  </div>
</div>
