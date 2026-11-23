{**
 * TopMarket Child Theme - Main Menu Override
 * Domitek E-Commerce (1:1 Układ menu TopMarket.pl: PROMOCJE na czerwono #d92829, kategorie, BESTSELLERY po prawej)
 *}
{assign var=_counter value=0}
{function name="menu" nodes=[] depth=0 parent=null}
  {if $nodes|count}
    <ul class="top-menu {if $depth == 0}topmarket-menu-primary{else}topmarket-submenu{/if}" {if $depth == 0}id="top-menu"{/if} data-depth="{$depth}">
      {foreach from=$nodes item=node}
        {assign var=_counter value=$_counter+1}
        {assign var=_node_id value="menu_node_"|cat:$_counter}
        {assign var=_is_promocje value=($node.label|lower == 'promocje' || $node.page_identifier == 'lnk-promocje')}
        {assign var=_is_bestsellery value=($node.label|lower == 'bestsellery' || $node.page_identifier == 'lnk-bestsellery')}
        <li class="{$node.type}{if $node.current} current{/if}{if $_is_promocje} menu-item-promocje{/if}{if $_is_bestsellery} menu-item-bestsellery{/if}" id="{$node.page_identifier|default:$_node_id}">
          <a
            class="{if $depth >= 0}dropdown-item{/if}{if $depth === 1} dropdown-submenu{/if}{if $_is_promocje} nav-link-promocje{/if}{if $_is_bestsellery} nav-link-bestsellery{/if}"
            href="{$node.url}" data-depth="{$depth}"
            {if $node.open_in_new_window} target="_blank" {/if}
          >
            <span class="menu-label-text">{$node.label}</span>
            {if $node.children|count && $depth == 0}
              <i class="material-icons menu-dropdown-icon hidden-sm-down" aria-hidden="true">&#xE313;</i>
              <span class="float-xs-right hidden-md-up">
                <span data-target="#top_sub_menu_{$_node_id}" data-toggle="collapse" class="navbar-toggler collapse-icons">
                  <i class="material-icons add">&#xE313;</i>
                  <i class="material-icons remove">&#xE316;</i>
                </span>
              </span>
            {/if}
          </a>
          {if $node.children|count}
            <div {if $depth === 0} class="popover sub-menu js-sub-menu collapse topmarket-dropdown-panel"{else} class="collapse"{/if} id="top_sub_menu_{$_node_id}">
              {menu nodes=$node.children depth=$node.depth parent=$node}
            </div>
          {/if}
        </li>
      {/foreach}
    </ul>
  {/if}
{/function}

<div class="menu js-top-menu position-static hidden-sm-down" id="_desktop_top_menu">
  {menu nodes=$menu.children}
  <div class="clearfix"></div>
</div>
