{assign var="noSidebar" value=true}
{include file='header.tpl'}

{block name='layout_options' prepend}
	{$layoutNoSidebar = !Config::Get('page.show_block_structure')}
{/block}

{if $oUserCurrent and $oUserCurrent->isAdministrator()}
	<span class="edit"><i class="icon-synio-actions-edit"></i><a href="{$oPage->getAdminEditWebUrl()}" class="actions-edit">Редактировать</a></span>
	<br />
{/if}

<h2 class="page-header">{$oPage->getTitle()|escape}</h2>

{$oPage->getText()}

{include file='footer.tpl'}
