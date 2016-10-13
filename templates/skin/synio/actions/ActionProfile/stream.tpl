{include file='header.tpl' menu='people'}

{include file='actions/ActionProfile/profile_top.tpl'}


{if count($aStreamEvents)}
	<ul class="stream-list" id="stream-list">
	{include file='actions/ActionStream/events.tpl'}
	</ul>

	{if !$bDisableGetMoreButton}
		<span class="stream-get-more" id="stream_get_more" data-last-id="{$iStreamLastId}" onclick="ls.stream.getMoreByUser({$oUserProfile->getId()})">{$aLang.stream_get_more} &darr;</span>
	{/if}
{else}
	{$aLang.stream_no_events}
{/if}



{include file='footer.tpl'}
