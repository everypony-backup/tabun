<div class="comments comment-list">
{foreach from=$aComments item=oComment}
    {assign var="oCommentAuthor" value=$oComment->getUser()}
    {assign var="oCommentAuthorLogin" value=$oCommentAuthor->getLogin()}
    {assign var="oCommentId" value=$oComment->getId()}
    {assign var="oTopic" value=$oComment->getTarget()}
    {if $oTopic}
        {assign var="oBlog" value=$oTopic->getBlog()}
    {/if}
    <section class="comment">
        <div class="comment-content">
            <div class="text">{$oComment->getText()}</div>
        </div>
        <div class="comment-info" data-id="{$oCommentId}">
            <a href="/profile/{$oCommentAuthorLogin}">
                <img src="{$oCommentAuthor->getProfileAvatarPath(24)}"  class="comment-avatar"/>
            </a>
            <a class="comment-author {if $iAuthorId == $oCommentAuthor->getId()}comment-topic-author{/if}" {if sAuthorNotice} title="{$sAuthorNotice}"{/if} href="/profile/{$oCommentAuthorLogin}">{$oCommentAuthorLogin}</a>
            <time class="comment-date" datetime="{date_format date=$oCommentDate format='c'}"
                      title="{date_format date=$oCommentDate hours_back="12" minutes_back="60" now="60" day="day H:i" format="j F Y, H:i"}">
                {date_format date=$oCommentDate format="j F Y, H:i"}
            </time>
            <a class="comment-link icon-synio-link" href="#comment{$oCommentId}" title="{$aLang.comment_url_notice}"></a>
            {if $oUserCurrent}
                {if !$bNoCommentFavourites}
                <div class="comment-favourite">
                    <div class="favourite {if $oComment->getIsFavourite()}active{/if}" data-target_id="{$oCommentId}" data-target_type="comment">
                        {if $oComment->getIsFavourite()}
                            {t}favourite_in{/t}
                        {else}
                            {t}favourite_add{/t}
                        {/if}
                    </div>
                    <span class="favourite-count" id="fav_count_comment_{$oCommentId}" {if $oComment->getCountFavourite() == 0}hidden{/if}>{if $oComment->getCountFavourite() > 0}{$oComment->getCountFavourite()}{/if}</span>
                </div>
                {/if}
            {/if}
            {if $oComment->getTargetType() != 'talk'}
                <div id="vote_area_comment_{$oCommentId}" class="vote comment-vote {if $oCommentRating > 0} vote-count-positive {elseif $oCommentRating < 0} vote-count-negative{/if}">
                    <span class="vote-count" id="vote_total_comment_{$oCommentId}">{if $oCommentRating > 0}+{/if}{$oCommentRating}</span>
                </div>
            {/if}
            <div>
                {if $oBlog}
                    <a href="{$oBlog->getUrlFull()}" class="blog-name">{$oBlog->getTitle()|escape:'html'}</a>
                    &rarr;
                {/if}
                <a href="{$oTopic->getUrl()}" class="comment-path-topic">{$oTopic->getTitle()|escape:'html'}</a>
                <a href="{$oTopic->getUrl()}#comments"  class="comment-path-comments">{$oTopic->getCountComment()}</a>
            </div>
            {include file='comment_modify_notice.tpl' bGetShort=true}
        </div>
    </section>
{/foreach}
</div>

{include file='paging.tpl' aPaging=$aPaging}