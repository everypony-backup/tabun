{include file='header.tpl' menu='blog'}
{include file='topic_list.tpl'}



{if count($aTopics)}
    {if !$bDisableGetMoreButton}
        <div id="userfeed_loaded_topics"></div>
        <span class="stream-get-more" id="userfeed_get_more" data-userfeed-last-id="{$iUserfeedLastId}" onclick="ls.userfeed.getMore()">{$aLang.userfeed_get_more} &darr;</span>
    {/if}
{else}
    {$aLang.userfeed_no_events}
{/if}



{include file='footer.tpl'}
