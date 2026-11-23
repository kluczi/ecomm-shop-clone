{**
 * TopMarket Child Theme - Searchbar Template Override
 * Domitek E-Commerce (1:1 Centralna wyszukiwarka TopMarket.pl: wys. 45.4px, białe tło, ramka 1px solid #e3e3e3, 0px border-radius)
 *}
<div id="search_widget" class="search-widget topmarket-search-widget" data-search-controller-url="{$search_controller_url}">
  <form method="get" action="{$search_controller_url}" role="search">
    <input type="hidden" name="controller" value="search">
    <label for="search_query_top" class="sr-only">Czego szukasz?</label>
    <div class="topmarket-search-input-wrap">
      <input
        type="text"
        id="search_query_top"
        name="s"
        value="{$search_string|default:''}"
        placeholder="Czego szukasz?"
        aria-label="Czego szukasz w sklepie?"
        autocomplete="off"
        class="topmarket-search-input"
      >
      <button type="submit" class="topmarket-search-btn" aria-label="Wyszukaj">
        <i class="material-icons search" aria-hidden="true">&#xE8B6;</i>
      </button>
    </div>
  </form>
</div>
