{assign var="noSidebar" value=true}
{include file='header.tpl' menu="stream"}

<h2 class="page-header">{$aLang.stream_menu}</h2>

{if count($aStreamEvents)}
	<ul class="stream-list" id="stream-list">
		{include file='actions/ActionStream/events.tpl'}
	</ul>

    {if !$bDisableGetMoreButton}
        <span class="stream-get-more" id="stream_get_more_all" data-last-id="{$iStreamLastId}">{$aLang.stream_get_more} &darr;</span>
    {/if}
{else}
    {$aLang.stream_no_events}
{/if}


{include file='footer.tpl'}