{include file='header.tpl'}

<h2 class="page-header">{$aLang.search}</h2>

{hook run='search_begin'}

<form action="{router page='search'}" class="search">
	{hook run='search_form_begin'}
	<input type="text" placeholder="{$aLang.search}" maxlength="255" name="q" class="input-text" value="{$sQuery|escape:'html'}">
	<input type="submit" value="" title="{$aLang.search_submit}" class="input-submit icon icon-search">
	<div class="block">
		Поиск по:
		<span class="input-radio">
			<input id="radio_t" type="radio" name="t" value="t" {if $sType == "t"}checked{/if}>
			<label for="radio_t">топикам</label>
		</span>
		<span class="input-radio">
			<input id="radio_c" type="radio" name="t" value="c" {if $sType == "c"}checked{/if}>
			<label for="radio_c">комментариям</label>
		</span>
	</div>
	{hook run='search_form_end'}
</form>

{if $iResCount > 0}
	<header class="search-header">
		<h3>Результатов: {$iResCount}</h3>
	</header>
	<div>
		{foreach from=$aResults item=aResult}
			{if $aResult._type == "topic"}topic{/if}
			{if $aResult._type == "comment"}comment{/if}
		{/foreach}
	</div>
{elseif $iResCount !== null}
	<header class="search-header">
		<h3>Нет результатов</h3>
	</header>
{/if}

{hook run='search_end'}

{include file='footer.tpl'}