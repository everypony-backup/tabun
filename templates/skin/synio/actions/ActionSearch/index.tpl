{include file='header.tpl' styles=['search']}

<h2 class="page-header">{$aLang.search}</h2>

<div data-bazooka="search_configurator"></div>

{if $iResCount > 0}
	<header class="search-header">
		<h3>Результатов: {$iResCount}</h3>
	</header>
	<div>
		{if $sType == 'topic'}
			{include file='topic_list.tpl'}
		{elseif $sType == 'comment'}
			{include file='comment_list.tpl'}
		{else}
			{hook run='search_result' sType=$sType}
		{/if}
	</div>
{elseif $iResCount !== null}
	<header class="search-header">
		<h3>Нет результатов</h3>
	</header>
{/if}


{include file='footer.tpl' scripts=["search"]}