{strip}
{assign var="oCommentAuthor" value=$oComment->getUser()}
{assign var="oCommentAuthorLogin" value=$oCommentAuthor->getLogin()}
{assign var="oCommentAuthorId" value=$oComment->getUserId()}
{assign var="oCommentId" value=$oComment->getId()}
{assign var="oCommentRating" value=$oComment->getRating()}
{assign var="oCommentDate" value=$oComment->getDate()}
{if $oUserCurrent}
    {assign var="oCommentVote" value=$oComment->getVote()}
    {assign var="editAccessMask" value=$LS->ACL_GetCommentEditAllowMask($oComment, $oUserCurrent, $bAllowUserToEditBlogComments)}
    {assign var="oCommentVoteCount" value=$oComment->getCountVote()}
	{if $bVoteInfoEnabledForTopic !== null}
		{assign var="bVoteInfoEnabled" value=$bVoteInfoEnabledForTopic}
	{else}
		{assign var="bVoteInfoEnabled" value=$LS->ACL_CheckSimpleAccessLevel($oConfig->GetValue('vote_state.comment.na_enable_level'), $oUserCurrent, $oComment, 'comment')}
	{/if}
    {if $oCommentAuthorId == $oUserCurrent->getId()}
        {assign var="oCommentSelf" value="comment-self"}
    {/if}
    {if $sDateReadLast <= $oCommentDate}
        {assign var="oCommentNew" value="comment-new"}
    {/if}
{/if}

{if $oCommentRating <= $oConfig->GetValue('module.user.bad_rating')}
    {if $oUserCurrent and $oUserCurrent->isAdministrator()}
        <section data-id="{$oCommentId}" id="comment_id_{$oCommentId}" class="comment comment-deleted comment-bad">
            <div class="text current">{$oComment->getText()}</div>
            <div class="comment-info" data-id="{$oCommentId}">
                <a href="/profile/{$oCommentAuthorLogin}" data-user_id="{$oCommentAuthorId}">
                    <img src="{$oCommentAuthor->getProfileAvatarPath(24)}" class="comment-avatar"/>
                </a>
                <a class="comment-author" href="/profile/{$oCommentAuthorLogin}">{$oCommentAuthorLogin}</a>
                <time class="comment-date" datetime="{date_format date=$oCommentDate format='c'}" title="{$oCommentDate}">
                    {date_format date=$oCommentDate format="j F Y, H:i"}
                </time>
                <a class="comment-link" href="#comment{$oCommentId}" title="{$aLang.comment_url_notice}"></a>
                <a class="goto goto-comment-parent" title="{$aLang.comment_goto_parent}">↑</a>
                <span>{$aLang.comment_was_hidden}</span>
            </div>
    {else}
        <section data-id="{$oCommentId}" id="comment_id_{$oCommentId}" class="comment comment-deleted">
            <div class="text current"><em>{$aLang.comment_was_hidden}</em></div>
            <div class="comment-info" data-id="{$oCommentId}"></div>
    {/if}
{elseif $oComment->getDelete()}
    {if $oUserCurrent and $oUserCurrent->isAdministrator()}
        <section data-id="{$oCommentId}" id="comment_id_{$oCommentId}" class="comment comment-deleted comment-bad">
            <div class="text current">{$oComment->getText()}</div>
            <div class="comment-info" data-id="{$oCommentId}">
                <a href="/profile/{$oCommentAuthorLogin}" data-user_id="{$oCommentAuthorId}">
                    <img src="{$oCommentAuthor->getProfileAvatarPath(24)}" class="comment-avatar"/>
                </a>
                <a class="comment-author" href="/profile/{$oCommentAuthorLogin}">{$oCommentAuthorLogin}</a>
                <time class="comment-date" datetime="{date_format date=$oCommentDate format='c'}" title="{$oCommentDate}">
                    {date_format date=$oCommentDate format="j F Y, H:i"}
                </time>
                <a class="comment-link" href="#comment{$oCommentId}" title="{$aLang.comment_url_notice}"></a>
                <a class="goto goto-comment-parent" title="{$aLang.comment_goto_parent}">↑</a>
                <a class="comment-repair link-dotted">{$aLang.comment_repair}</a>
                <span>{$aLang.comment_was_delete}</span>
            </div>
    {else}
        <section data-id="{$oCommentId}" id="comment_id_{$oCommentId}" class="comment comment-deleted">
            <div class="text current"><em>{$aLang.comment_was_delete}</em></div>
            <div class="comment-info" data-id="{$oCommentId}"></div>
    {/if}
{else}
    <section data-id="{$oCommentId}" id="comment_id_{$oCommentId}" class="comment {if $oComment->isBad()}comment-bad{/if} {$oCommentSelf} {$oCommentNew}">
        <div id="comment_content_id_{$oCommentId}" class="comment-content">
            <div class="text current">{$oComment->getText()}</div>
        </div>
        <div class="comment-info" data-id="{$oCommentId}">
            <a href="/profile/{$oCommentAuthorLogin}" data-user_id="{$oCommentAuthorId}">
                <img src="{$oCommentAuthor->getProfileAvatarPath(24)}" class="comment-avatar"/>
            </a>
            <a class="comment-author {if $iAuthorId == $oCommentAuthorId}comment-topic-author {if $sAuthorNotice}" title="{$sAuthorNotice}{/if}{/if}" href="/profile/{$oCommentAuthorLogin}">{$oCommentAuthorLogin}</a>
            <time class="comment-date" datetime="{date_format date=$oCommentDate format='c'}" title="{$oCommentDate}">
                {date_format date=$oCommentDate format="j F Y, H:i"}
            </time>
            <a class="comment-link" href="#comment{$oCommentId}" title="{$aLang.comment_url_notice}"></a>
            <a class="goto goto-comment-parent" title="{$aLang.comment_goto_parent}">↑</a>
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
                <div id="vote_area_comment_{$oCommentId}" class="vote comment-vote
                    {if $oCommentVoteCount > 0}
                        {if $oCommentRating > 0} vote-count-positive
                        {elseif $oCommentRating < 0} vote-count-negative
                        {else} vote-count-mixed
                        {/if}
                    {/if}
                    {if $oCommentVote} voted
                        {if $oCommentVote->getDirection() > 0} voted-up
                        {else} voted-down
                        {/if}
                    {elseif !isset($oCommentSelf)}
                        {if $oUserCurrent and !$oCommentVote and $oComment->getTargetType() == 'topic' and (strtotime($oCommentDate)>=time()-$oConfig->GetValue('acl.vote.comment.limit_time')) and $LS->ACL_CanVoteComment($oUserCurrent, $oComment)} vote-enabled{/if}
                    {/if}
                    {if $bVoteInfoEnabled} vote-info-enabled{/if}">
                    <div class="vote-item vote-up" data-direction="1" data-target_id="{$oCommentId}" data-target_type="comment"></div>
                    <span class="vote-count" id="vote_total_comment_{$oCommentId}" data-target_id="{$oCommentId}" data-target_type="comment" data-count="{$oCommentVoteCount}">{$oCommentRating}</span>
                    <div class="vote-item vote-down" data-direction="-1" data-target_id="{$oCommentId}" data-target_type="comment"></div>
                </div>
                {/if}
                <a class="reply-link link-dotted">{$aLang.comment_answer}</a>
                <a class="comment-delete link-dotted">{$aLang.comment_delete}</a>
                {if $oComment->testAllowEdit($editAccessMask)}
                    <a class="link-dotted comment-edit-bw" data-lock="{if $oComment->testAllowLock($editAccessMask)}true{else}false{/if}">{$aLang.comment_edit}</a>
                    <a class="link-dotted comment-save-edit-bw">{$aLang.comment_save_edit}</a>
                    <a class="link-dotted comment-preview-edit-bw">{$aLang.comment_preview_edit}</a>
                    <a class="link-dotted comment-cancel-edit-bw">{$aLang.comment_cancel_edit}</a>
                {/if}
                {hook run='comment_action' comment=$oComment}
                {include file='comment_modify_notice.tpl'}
            {/if}
        </div>
{/if}
    </section>
    <div class="folding"></div>
{/strip}