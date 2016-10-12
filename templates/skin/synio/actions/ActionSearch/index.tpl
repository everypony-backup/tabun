{include file='header.tpl' styles=['search']}

<h2 class="page-header">{$aLang.search}</h2>

<div data-bazooka="search_configurator"></div>

<header class="search-header">
	{if $iResCount > 0}
		<h3>Результатов: {$iResCount}</h3>
	{else}
		<h3>Нет результатов</h3>
	{/if}
</header>

<div>
	{if isset($aTopics)}
		{include file='topic_list.tpl'}
	{elseif isset($aComments)}
		{include file='comment_list.tpl'}
	{else}

	{/if}
</div>

{include file='footer.tpl' scripts=["search"]}