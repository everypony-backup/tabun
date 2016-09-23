{include file='header.tpl'}

<h2 class="page-header">{$aLang.search}</h2>


<!--
<form action="{router page='search'}" class="search">
	<input type="text" placeholder="{$aLang.search}" maxlength="255" name="q" class="input-text" value="{$sQuery|escape:'html'}">
	<input type="submit" value="" title="{$aLang.search_submit}" class="input-submit icon icon-search">
	<div class="block">
		<div>
			Сортировать по:
			<span class="input-radio">
				<input id="radio_sort_date" type="radio" name="sort" value="date" {if $sSort == "date"}checked{/if}>
				<label for="radio_sort_date">дате</label>
			</span>
			<span class="input-radio">
				<input id="radio_sort_score" type="radio" name="sort" value="score" {if $sSort == "score"}checked{/if}>
				<label for="radio_sort_score">релевантности</label>
			</span>
			<span class="input-radio">
				<input id="radio_sort_rating" type="radio" name="sort" value="rating" {if $sSort == "rating"}checked{/if}>
				<label for="radio_sort_rating">рейтингу</label>
			</span>
		</div>
		<div>
			Поиск по:
			<span class="input-radio">
				<input id="radio_type_topic" type="radio" name="type" value="topic" {if $sType == "topic"}checked{/if}>
				<label for="radio_type_topic">топикам</label>
			</span>
			<span class="input-radio">
				<input id="radio_type_comment" type="radio" name="type" value="comment" {if $sType == "comment"}checked{/if}>
				<label for="radio_type_comment">комментариям</label>
			</span>
		</div>

	</div>
</form>
-->
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