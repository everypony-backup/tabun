<div class="comments comment-list">
{foreach from=$aComments item=oComment}
    {assign var="oTopic" value=$oComment->getTarget()}
    {if $oTopic}
        {assign var="bAuthorNotice" value=$oTopic->getUserId() == $oComment->getUserId()}
    {/if}
    {include
        file='comment.tpl'
        bShort=true
        bNoCommentFavourites=false
        sAuthorNotice=$aLang.topic_author
    }
{/foreach}
</div>

{include file='paging.tpl' aPaging=$aPaging}
