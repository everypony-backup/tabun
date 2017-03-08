{strip}
{if $oUserCurrent}
    {assign var="oUserIsAdmin" value=$oUserCurrent->isAdministrator()}
    {assign var="oCommentVote" value=$oComment->getVote()}
    {assign var="editAccessMask" value=$oComment->getEditAccessMask($oUserCurrent)}
{/if}
{assign var="oCommentAuthor" value=$oComment->getUser()}
{assign var="oCommentAuthorLogin" value=$oCommentAuthor->getLogin()}
{assign var="oCommentId" value=$oComment->getId()}
{assign var="oCommentRating" value=$oComment->getRating()}
{assign var="oCommentDate" value=$oComment->getDate()}
{assign var="oCommentDeleted" value=$oComment->getDelete()}
{if $bVoteInfoEnabled === null}
    {assign var="bVoteInfoEnabled" value=$LS->ACL_CheckSimpleAccessLevel($oConfig->GetValue('vote_state.comment.ne_enable_level'), $oUserCurrent, $oComment, 'comment')}
{/if}

<section data-id="{$oCommentId}" id="comment_id_{$oCommentId}" class="comment {if $oCommentDeleted}comment-deleted {/if}{if $oComment->isBad()}comment-bad {/if}{if $oUserCurrent}{if $oComment->getUserId() == $oUserCurrent->getId()}comment-self {elseif $sDateReadLast <= $oCommentDate}comment-new{/if}{/if}">
    <div id="comment_content_id_{$oCommentId}" class="comment-content">
        <div class="text current">
            {if !$oCommentDeleted and ($oCommentRating > $oConfig->GetValue('module.user.bad_rating'))}
                {$oComment->getText()}
            {elseif  $bOneComment or $oUserIsAdmin}
                {$oComment->getText()}
            {elseif $oCommentDeleted}
                <em>{$aLang.comment_was_delete}</em>
            {else}
                <em>{$aLang.comment_was_hidden}</em>
            {/if}
        </div>
    </div>
    <div class="comment-info" data-id="{$oCommentId}">
        <a href="/profile/{$oCommentAuthorLogin}" data-user_id="{$oCommentAuthor->getId()}">
            <img src="{$oCommentAuthor->getProfileAvatarPath(24)}"  class="comment-avatar"/>
        </a>
        <a class="comment-author {if $iAuthorId == $oCommentAuthor->getId()}comment-topic-author{/if}" {if sAuthorNotice} title="{$sAuthorNotice}"{/if} href="/profile/{$oCommentAuthorLogin}">{$oCommentAuthorLogin}</a>
        <time class="comment-date" datetime="{date_format date=$oCommentDate format='c'}" title="{date_format date=$oCommentDate hours_back="12" minutes_back="60" now="60" day="day H:i" format="j F Y, H:i"}">
            {date_format date=$oCommentDate format="j F Y, H:i"}
        </time>
        <a class="comment-link" href="#comment{$oCommentId}" title="{$aLang.comment_url_notice}"></a>
        {if $oComment->getPid()}
            <a class="goto goto-comment-parent" title="{$aLang.comment_goto_parent}">↑</a>
        {/if}
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
            {if !$oCommentDeleted}
                {if !$bAllowNewComment}
                    <a class="reply-link link-dotted">{$aLang.comment_answer}</a>
                {/if}
                {if $oUserIsAdmin}
                    <a class="comment-delete link-dotted">{$aLang.comment_delete}</a>
                {/if}
            {elseif $oUserIsAdmin}
                <a class="comment-repair link-dotted">{$aLang.comment_repair}</a>
            {/if}
            {if $oComment->testAllowEdit($editAccessMask)}
                <a class="link-dotted comment-edit-bw" data-lock="{if $oComment->testAllowLock($editAccessMask)}true{else}false{/if}">{$aLang.comment_edit}</a>
                <a class="link-dotted comment-save-edit-bw">{$aLang.comment_save_edit}</a>
                <a class="link-dotted comment-preview-edit-bw">{$aLang.comment_preview_edit}</a>
                <a class="link-dotted comment-cancel-edit-bw">{$aLang.comment_cancel_edit}</a>
            {/if}
            {if $oComment->getTargetType() != 'talk'}
                <div id="vote_area_comment_{$oCommentId}" class="vote comment-vote
                    {if $oCommentRating > 0}
                        vote-count-positive
                    {elseif $oCommentRating < 0}
                        vote-count-negative
                    {elseif $oCommentRating == 0 and $bVoteInfoEnabled and $oComment->getCountVote() > 0}
                        vote-count-mixed
                    {/if}
                    {if $oCommentVote}
                        voted
                            {if $oCommentVote->getDirection() > 0}
                                voted-up
                            {else}
                                voted-down
                            {/if}
                    {/if}
                    {if $bVoteInfoEnabled} vote-info-enable{/if}">
                    <div class="vote-item vote-up" data-direction="1" data-target_id="{$oCommentId}" data-target_type="comment"></div>
                    <span class="vote-count" id="vote_total_comment_{$oCommentId}" {if $bVoteInfoEnabled}data-count="{$oComment->getCountVote()}" onclick="ls.vote.getVotes({$oComment->getId()},'comment',this);"{/if}>{if $oCommentRating > 0}+{/if}{$oCommentRating}</span>
                    <div class="vote-item vote-down" data-direction="-1" data-target_id="{$oCommentId}" data-target_type="comment"></div>
                </div>
            {/if}
            {hook run='comment_action' comment=$oComment}
            {include file='comment_modify_notice.tpl'}
        {/if}
    </div>
</section>
<div class="folding"></div>
{/strip}