{assign var="noSidebar" value=true}
{include file='header.tpl'}

{block name='layout_options' prepend}
	{$layoutNoSidebar = !Config::Get('page.show_block_structure')}
{/block}

<h2 class="page-header">{$oPage->getTitle()|escape}</h2>

{$oPage->getText()}

{if $oUserCurrent and $oUserCurrent->isAdministrator()}
    <br />
    <a href="{$oPage->getAdminEditWebUrl()}">Редактировать</a>
{/if}

{include file='footer.tpl'}