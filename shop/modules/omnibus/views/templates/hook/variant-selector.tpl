<div class="product-variants mt-3">
  <span class="control-label">{$variant_label|escape:'html':'UTF-8'}</span>
  <ul class="list-inline mb-0">
    {foreach $variant_options as $option}
      <li class="list-inline-item">
        <a href="{$option.url|escape:'html':'UTF-8'}"
           class="btn btn-sm {if $option.selected}btn-primary{else}btn-outline-primary{/if}"
           {if $option.selected}aria-current="page"{/if}>
          {$option.label|escape:'html':'UTF-8'}
        </a>
      </li>
    {/foreach}
  </ul>
</div>
