<div class="comments comment-list">
    {foreach from=$aComments item=oComment}
        {assign var="oUser" value=$oComment->getUser()}
        {assign var="oTopic" value=$oComment->getTarget()}
        {if $oTopic}
            {assign var="oBlog" value=$oTopic->getBlog()}
        {/if}
        <section class="comment">

            <div class="comment-content">
                <div class="text">{$oComment->getText()}</div>
            </div>

            <div class="comment-path">

                <ul class="comment-info">
                    <li class="comment-author">
                        <a href="{$oUser->getUserWebPath()}">
					<img src="{$oUser->getProfileAvatarPath(24)}"  class="comment-avatar" />
                        </a>
                        <a href="{$oUser->getUserWebPath()}">{$oUser->getLogin()}</a>
                    </li>
                    <li class="comment-date">
                        <time datetime="{date_format date=$oComment->getDate() format='c'}"
                              title="{date_format date=$oComment->getDate()
					  format="j F Y, H:i"}"
                >
					{date_format date=$oComment->getDate() hours_back="12" minutes_back="60" now="60" day="day H:i" format="j F Y, H:i"}
                        </time>
                    </li>
                    {if $oComment->getTargetType() != 'talk'}
                            <li id="vote_area_comment_{$oComment->getId()}"
                                class="vote
                                {if $oComment->getRating() > 0}
                                    vote-count-positive
                                {elseif $oComment->getRating() < 0}
                                    vote-count-negative
                                {/if}
                            ">
                                <span class="vote-count" id="vote_total_comment_{$oComment->getId()}">{$oComment->getRating()}</span>
                            </li>
                    {/if}
                    {if $oUserCurrent and !$bNoCommentFavourites}
                        <li class="comment-favourite">
                            <div onclick="return ls.favourite.toggle({$oComment->getId()},this,'comment');"
                                 class="favourite {if $oComment->getIsFavourite()}active{/if}">В избранное
                            </div>
                            <span class="favourite-count" id="fav_count_comment_{$oComment->getId()}" {if $oComment->getCountFavourite() == 0}hidden{/if}>{if $oComment->getCountFavourite() > 0}{$oComment->getCountFavourite()}{/if}</span>
                        </li>
                    {/if}
                    <li class="comment-link">
                        <a href="{$oTopic->getUrl()}#comment{$oComment->getId()}" title="{$aLang.comment_url_notice}">
                            <i class="icon-synio-link"></i>
                        </a>
                    </li>
                    {if $oComment->getPid()}
                        <li class="goto goto-comment-parent">
                            <a href="{router page='comments'}{$oComment->getPid()}"
                                onclick="ls.comments.goToParentComment({$oComment->getId()},{$oComment->getPid()}); return false;"
                                title="{$aLang.comment_goto_parent}">↑</a>
                        </li>
                    {/if}
                    <li>
                        {if $oBlog}
                            <a href="{$oBlog->getUrlFull()}" class="blog-name">{$oBlog->getTitle()|escape:'html'}</a>
                            &rarr;
                        {/if}
                        <a href="{$oTopic->getUrl()}" class="comment-path-topic">{$oTopic->getTitle()|escape:'html'}</a>
                        <a href="{$oTopic->getUrl()}#comments"  class="comment-path-comments">{$oTopic->getCountComment()}</a>
                    </li>
					{include file='comment_modify_notice.tpl' bGetShort=true}
                </ul>
            </div>
        </section>
    {/foreach}
</div>

{include file='paging.tpl' aPaging=$aPaging}