{strip}
{if $oUserCurrent}
    {assign var="oUserIsAdmin" value=$oUserCurrent->isAdministrator()}
    {assign var="oCommentVote" value=$oComment->getVote()}
    {assign var="editAccessMask" value=$oComment->getEditAccessMask($oUserCurrent)}
	{if $bVoteInfoEnabled === null}
		{assign var="bVoteInfoEnabled" value=$LS->ACL_CheckSimpleAccessLevel($oConfig->GetValue('vote_state.comment.na_enable_level'), $oUserCurrent, $oComment, 'comment')}
	{/if}
    {if $oComment->getUserId() == $oUserCurrent->getId()}
        {assign var="oCommentSelf" value="comment-self"}
    {/if}
    {if $sDateReadLast <= $oCommentDate}
        {assign var="oCommentNew" value="comment-new"}
    {/if}
{/if}
{assign var="oCommentAuthor" value=$oComment->getUser()}
{assign var="oCommentAuthorLogin" value=$oCommentAuthor->getLogin()}
{assign var="oCommentId" value=$oComment->getId()}
{assign var="oCommentRating" value=$oComment->getRating()}
{assign var="oCommentDate" value=$oComment->getDate()}
{assign var="oCommentDeleted" value=$oComment->getDelete()}

<section data-id="{$oCommentId}" id="comment_id_{$oCommentId}" class="comment {if $oCommentDeleted}comment-deleted {/if}{if $oComment->isBad()}comment-bad{/if} {$oCommentSelf} {$oCommentNew}">
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
            <img src="{$oCommentAuthor->getProfileAvatarPath(24)}" class="comment-avatar"/>
        </a>
        <a class="comment-author {if $iAuthorId == $oCommentAuthor->getId()}comment-topic-author {if $sAuthorNotice}" title="{$sAuthorNotice}{/if}{/if}" href="/profile/{$oCommentAuthorLogin}">{$oCommentAuthorLogin}</a>
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
                {if $oComment->getCountFavourite() > 0}
                    <div class="favourite{if $oComment->getIsFavourite()} active{/if}" data-target_id="{$oCommentId}" data-target_type="comment">
                        {if $oComment->getIsFavourite()}
                            {$aLang.comment_favourite_add_already}
                        {else}
                            {$aLang.comment_favourite_add}
                        {/if}
                    </div>
                    <span class="favourite-count" id="fav_count_comment_{$oCommentId}">{$oComment->getCountFavourite()}</span>
                {else}
                    <div class="favourite" data-target_id="{$oCommentId}" data-target_type="comment">{$aLang.comment_favourite_add}</div>
                    <span class="favourite-count" id="fav_count_comment_{$oCommentId}"></span>
                {/if}
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
                    {if $oComment->getCountVote() > 0}
                        {if $oCommentRating > 0} vote-count-positive
                        {elseif $oCommentRating < 0} vote-count-negative
                        {else} vote-count-mixed
                        {/if}
                        {if $oCommentVote} voted
                            {if $oCommentVote->getDirection() > 0} voted-up
                            {else} voted-down
                            {/if}
                        {/if}
                    {/if}
                    {if $bVoteInfoEnabled} vote-info-enabled{/if}
                    {if $LS->ACL_CanVoteComment($oUserCurrent, $oComment, false, $oCommentVote)} vote-enabled{/if}">
                    <div class="vote-item vote-up" data-direction="1" data-target_id="{$oCommentId}" data-target_type="comment"></div>
                    <span class="vote-count" id="vote_total_comment_{$oCommentId}" data-target_id="{$oCommentId}" data-target_type="comment" {if $bVoteInfoEnabled}data-count="{$oComment->getCountVote()}"{/if}>{$oCommentRating}</span>
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