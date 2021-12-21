{include file='header.tpl' menu='people'}

{include file='actions/ActionProfile/profile_top.tpl'}


{if count($aStreamEvents)}
	<ul class="stream-list" id="stream-list">
	{include file='actions/ActionStream/events.tpl'}
	</ul>

	{if !$bDisableGetMoreButton}
		<span class="stream-get-more" id="stream_get_more_by_user" data-last-id="{$iStreamLastId}" data-user_id="{$oUserProfile->getId()}">{$aLang.stream_get_more} &darr;</span>
	{/if}
{else}
	{$aLang.stream_no_events}
{/if}



{include file='footer.tpl'}
