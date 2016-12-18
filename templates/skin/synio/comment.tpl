{assign var="oUserIsAdmin" value=$oUserCurrent->isAdministrator()}
{assign var="oCommentAuthor" value=$oComment->getUser()}
{assign var="oCommentAuthorLogin" value=$oCommentAuthor->getLogin()}
{assign var="oCommentAuthorPath" value='/profile/$oCommentAuthorLogin'}
{assign var="oCommentVote" value=$oComment->getVote()}
{assign var="oCommentId" value=$oComment->getId()}
{assign var="oCommentRating" value=$oComment->getRating()}
{assign var="oCommentDate" value=$oComment->getDate()}
{assign var="oCommentDeleted" value=$oComment->getDelete()}
{assign var="editAccessMask" value=$oComment->getEditAccessMask($oUserCurrent)}

<section data-id="{$oCommentId}" id="comment_id_{$oCommentId}" class="comment {if $oCommentDeleted}comment-deleted {/if}{if $oComment->isBad()}comment-bad {/if}{if $oUserCurrent}{if $oComment->getUserId() == $oUserCurrent->getId()}comment-self {elseif $sDateReadLast <= $oCommentDate}comment-new{/if}{/if}">
    <div data-id="{$oCommentId}" class="folding"></div>
    <div id="comment_content_id_{$oCommentId}" class="comment-content">
        <div class="text">
            {if !$oCommentDeleted and ($oCommentRating > $oConfig->GetValue('module.user.bad_rating'))}
                {$oComment->getText()}
            {elseif  $bOneComment or ($oUserCurrent and $oUserIsAdmin)}
                {$oComment->getText()}
            {elseif $oCommentDeleted}
                <em>{$aLang.comment_was_delete}</em>
            {else}
                <em>{$aLang.comment_was_hidden}</em>
            {/if}
        </div>
    </div>
    <div class="comment-info">
        <a href="{$oCommentAuthorPath}">
            <img src="{$oCommentAuthor->getProfileAvatarPath(24)}"  class="comment-avatar"/>
        </a>
        <a class="comment-author {if $iAuthorId == $oCommentAuthor->getId()}comment-topic-author{/if}" {if sAuthorNotice} title="{$sAuthorNotice}"{/if} href="{$oCommentAuthorPath}">{$oCommentAuthorLogin}</a>
        <time class="comment-date" datetime="{date_format date=$oCommentDate format='c'}"
                  title="{date_format date=$oCommentDate hours_back="12" minutes_back="60" now="60" day="day H:i" format="j F Y, H:i"}">
            {date_format date=$oCommentDate format="j F Y, H:i"}
        </time>
        <a class="comment-link icon-synio-link" href="#comment{$oCommentId}" title="{$aLang.comment_url_notice}"></a>
        {if $oComment->getPid()}
            <a class="goto goto-comment-parent" href="#" onclick="ls.comments.showComment({$oCommentId},true); return false;" title="{$aLang.comment_goto_parent}">↑</a>
        {/if}
        {if $oUserCurrent}
            {!$bNoCommentFavourites}
            <div class="comment-favourite">
                <div onclick="return ls.favourite.toggle({$oCommentId},this,'comment');"
                     class="favourite {if $oComment->getIsFavourite()}active{/if}">
                    {if $oComment->getIsFavourite()}
                        {t}favourite_in{/t}
                    {else}
                        {t}favourite_add{/t}
                    {/if}
                </div>
                <span class="favourite-count" id="fav_count_comment_{$oCommentId}" {if $oComment->getCountFavourite() == 0}hidden{/if}>{if $oComment->getCountFavourite() > 0}{$oComment->getCountFavourite()}{/if}</span>
            </div>
            {/if}
            {if !$oCommentDeleted}
                {if !$bAllowNewComment}
                    <a href="#" onclick="ls.comments.toggleCommentForm({$oCommentId}); return false;" class="reply-link link-dotted">{$aLang.comment_answer}</a>
                {/if}
                {if $oUserIsAdmin}
                    <a href="#" class="comment-delete link-dotted" onclick="ls.comments.toggle(this,{$oCommentId}); return false;">{$aLang.comment_delete}</a>
                {/if}
            {elseif $oUserIsAdmin}
                <a href="#" class="comment-repair link-dotted" onclick="ls.comments.toggle(this,{$oCommentId}); return false;">{$aLang.comment_repair}</a>
            {/if}
            {if $oComment->testAllowEdit($editAccessMask)}
                <a href="#" class="link-dotted comment-edit-bw" onclick="return ls.comments.toggleEditForm({$oCommentId}, true, {if $oComment->testAllowLock($editAccessMask)}true{else}false{/if});">{$aLang.comment_edit}</a>
                <a href="#" class="link-dotted comment-save-edit-bw" onclick="return ls.comments.saveEdit({$oCommentId});">{$aLang.comment_save_edit}</a>
                <a href="#" class="link-dotted comment-preview-edit-bw" onclick="return ls.comments.previewEdit({$oCommentId});">{$aLang.comment_preview_edit}</a>
                <a href="#" class="link-dotted comment-cancel-edit-bw" onclick="return ls.comments.toggleEditForm({$oCommentId}, false);">{$aLang.comment_cancel_edit}</a>
            {/if}
            {if $oComment->getTargetType() != 'talk'}
                <div id="vote_area_comment_{$oCommentId}"
                    class="vote
                    {if $oCommentRating > 0}
                        vote-count-positive
                    {elseif $oCommentRating < 0}
                        vote-count-negative
                    {/if}
                    {if $oCommentVote}
                        voted
                            {if $oCommentVote->getDirection() > 0}
                                voted-up
                            {else}
                                voted-down
                            {/if}
                     {/if}">
                    <div class="vote-up" onclick="return ls.vote.vote({$oCommentId},this,1,'comment');"></div>
                    <span class="vote-count" id="vote_total_comment_{$oCommentId}">{if $oCommentRating > 0}+{/if}{$oCommentRating}</span>
                    <div class="vote-down" onclick="return ls.vote.vote({$oCommentId},this,-1,'comment');"></div>
                </div>
            {/if}
            {hook run='comment_action' comment=$oComment}
            {include file='comment_modify_notice.tpl'}
        {/if}
    </div>
</section>