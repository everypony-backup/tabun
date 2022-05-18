{*
    Этот шаблон подключается в comment_list.tpl и comment_tree.tpl и используется
    как для постов, так и для личных сообщений. Также он используется в классе
    Comment.class.php для ajax-подгрузки (функция GetCommentsNewByTargetId).

    Для его корректной работы нужно заранее объявить следующие переменные:

    - bShort: использовать ли упрощённый вид (для списков комментариев)
    - bAuthorNotice: добавлять ли уведомление об авторстве топика/сообщения
    - sAuthorNotice: текст уведомления об авторстве
    - bNoCommentFavourites: скрывать ли избранное и рейтинг
    - sDateReadLast (при bShort=false): если дата комментария позже этой даты,
      то он считается новым
    - oTopic (при bShort=true): для отображения ссылки на пост
*}

{assign var="oCommentAuthor" value=$oComment->getUser()}
{assign var="oCommentAuthorLogin" value=$oCommentAuthor->getLogin()}
{assign var="oCommentAuthorId" value=$oComment->getUserId()}
{assign var="oCommentId" value=$oComment->getId()}
{assign var="oCommentRating" value=$oComment->getRating()}
{assign var="oCommentVoteCount" value=$oComment->getCountVote()}
{assign var="oCommentDate" value=$oComment->getDate()}

{if $oUserCurrent and not $bShort}
    {assign var="oCommentVote" value=$oComment->getVote()}
    {if $sDateReadLast <= $oCommentDate}
        {assign var="oCommentNew" value="comment-new"}
    {/if}
{/if}
{if $oUserCurrent and $oCommentAuthorId == $oUserCurrent->getId()}
    {assign var="oCommentSelf" value="comment-self"}
{/if}

{if $oUserCurrent and $oUserCurrent->isAdministrator()}
    {assign var="bHideComment" value=false}
{else}
    {assign var="bHideComment" value=$oComment->getDelete() or $oComment->isHidden()}
{/if}

{if $oComment->getDelete()}
    {assign var="oCommentStateClass" value="comment-deleted"}
{elseif $oComment->isHidden()}
    {assign var="oCommentStateClass" value="comment-bad comment-hidden"}
{elseif $oComment->isBad()}
    {assign var="oCommentStateClass" value="comment-bad"}
{/if}

<section data-id="{$oCommentId}" id="comment_id_{$oCommentId}" class="comment {$oCommentStateClass} {$oCommentSelf} {$oCommentNew}">
    <a id="comment{$oCommentId}"></a>
    <div id="comment_content_id_{$oCommentId}" class="comment-content">
        {if $bHideComment and $oComment->getDelete()}
            <div class="text current"><em>{$aLang.comment_was_delete}</em></div>
        {elseif $bHideComment and $oComment->isHidden()}
            <div class="text current"><em>{$aLang.comment_was_hidden}</em></div>
        {else}
            <div class="text current">{$oComment->getText()}</div>
        {/if}
    </div>

    <div class="comment-info" data-id="{$oCommentId}">
        {if not $bHideComment}
            <a href="/profile/{$oCommentAuthorLogin}/" data-user_id="{$oCommentAuthorId}">
                <img src="{$oCommentAuthor->getProfileAvatarPath(24)}" class="comment-avatar"/>
            </a>
            <a class="comment-author{if $bAuthorNotice} comment-topic-author{/if}"{if $bAuthorNotice and $sAuthorNotice} title="{$sAuthorNotice}"{/if} href="/profile/{$oCommentAuthorLogin}/">{$oCommentAuthorLogin}</a>

            <time class="comment-date" datetime="{date_format date=$oCommentDate format='c'}" title="{date_format date=$oCommentDate hours_back="12" minutes_back="60" now="60" day="day H:i" format="j F Y, H:i"}">
                {date_format date=$oCommentDate format="j F Y, H:i"}
            </time>

            {if not $bShort}
                <a class="comment-link" href="#comment{$oCommentId}" title="{$aLang.comment_url_notice}"></a>
                {if $oComment->getPid()}
                    <a href="#comment{$oComment->getPid()}" class="goto goto-comment-parent" title="{$aLang.comment_goto_parent}">↑</a>
                {/if}
            {else}
                <a class="comment-link" href="/comments/{$oCommentId}" title="{$aLang.comment_url_notice}"></a>
                {if $oComment->getPid()}
                    <a href="/comments/{$oComment->getPid()}" class="goto goto-comment-parent" title="{$aLang.comment_goto_parent}">↑</a>
                {/if}
            {/if}

            {if $oComment->getDelete()}
                {if not $bShort}
                    <a class="comment-repair link-dotted">{$aLang.comment_repair}</a>
                {/if}
                <span>{$aLang.comment_was_delete}</span>
            {elseif $oComment->isHidden()}
                <span>{$aLang.comment_was_hidden}</span>
            {/if}

            {if $oUserCurrent}
                {if !$bNoCommentFavourites}
                    {if not $oComment->getDelete()}
                        <div class="comment-favourite">
                            {if $oComment->getCountFavourite() > 0}
                                <div class="favourite link-dotted{if $oComment->getIsFavourite()} active{/if}" data-target_id="{$oCommentId}" data-target_type="comment">
                                    {if $oComment->getIsFavourite()}
                                        {$aLang.comment_favourite_add_already}
                                    {else}
                                        {$aLang.comment_favourite_add}
                                    {/if}
                                </div>
                                <span class="favourite-count" id="fav_count_comment_{$oCommentId}">{$oComment->getCountFavourite()}</span>
                            {else}
                                <div class="favourite link-dotted" data-target_id="{$oCommentId}" data-target_type="comment">{$aLang.comment_favourite_add}</div>
                                <span class="favourite-count" id="fav_count_comment_{$oCommentId}"></span>
                            {/if}
                        </div>
                    {/if}

                    {if not $bShort}
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
                                {if (strtotime($oCommentDate)>=time()-$oConfig->GetValue('acl.vote.comment.limit_time'))} vote-enabled{/if}
                            {/if}
                            ">
                            <div class="vote-item vote-up" data-direction="1" data-target_id="{$oCommentId}" data-target_type="comment"></div>
                            <span class="vote-count" id="vote_total_comment_{$oCommentId}" data-target_id="{$oCommentId}" data-target_type="comment" data-count="{$oCommentVoteCount}">{if $oCommentRating > 0}+{/if}{$oCommentRating}</span>
                            <div class="vote-item vote-down" data-direction="-1" data-target_id="{$oCommentId}" data-target_type="comment"></div>
                        </div>
                    {else}
                        {assign var="bVoteInfoEnabled" value=$oUserCurrent and $LS->ACL_CheckSimpleAccessLevel($oConfig->GetValue('vote_state.comment.na_enable_level'), $oUserCurrent, $oComment, 'comment')}
                        <div id="vote_area_comment_{$oCommentId}" class="vote comment-vote
                            {if $oCommentVoteCount > 0}
                                {if $oCommentRating > 0} vote-count-positive
                                {elseif $oCommentRating < 0} vote-count-negative
                                {else} vote-count-mixed
                                {/if}
                            {/if}
                            {if $bVoteInfoEnabled} vote-info-enabled{/if}">
                            <span class="vote-count" id="vote_total_comment_{$oCommentId}" data-target_id="{$oCommentId}" data-target_type="comment" data-count="{$oCommentVoteCount}">{if $oCommentRating > 0}+{/if}{$oCommentRating}</span>
                        </div>
                    {/if}
                {/if}

                {if not $bShort and not $oComment->getDelete()}
                    <a class="reply-link link-dotted">{$aLang.comment_answer}</a>
                    <a class="link-dotted comment-delete">{$aLang.comment_delete}</a>
                    <a class="link-dotted comment-edit-bw {if (strtotime($oCommentDate)<=time()-$oConfig->GetValue('acl.edit.comment.limit_time'))} edit-timeout{/if}">{$aLang.comment_edit}</a>
                    {hook run='comment_action' comment=$oComment}
                {/if}
            {/if}
            {include file='comment_modify_notice.tpl' bGetShort=$bShort}
            {if $bShort and $oTopic}
                {assign var="oBlog" value=$oTopic->getBlog()}
                <div>
                    {if $oBlog}
                        <a href="{$oBlog->getUrlFull()}" class="blog-name">{$oBlog->getTitle()|escape:'html'}</a>
                        &rarr;
                    {/if}
                    <a href="{$oTopic->getUrl()}" class="comment-path-topic">{$oTopic->getTitle()|escape:'html'}</a>
                    <a href="{$oTopic->getUrl()}#comments"  class="comment-path-comments">{$oTopic->getCountComment()}</a>
                </div>
            {/if}
        {/if}
    </div>
</section>
{if not $bShort}
    <div class="folding"></div>
{/if}
