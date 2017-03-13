{include file='header.tpl'}

{include file='menu.talk.tpl'}

{assign var="oUser" value=$oTalk->getUser()}
{assign var="oTalkId" value=$oTalk->getId()}

<article class="topic topic-type-talk">
	<header class="topic-header">
		<h1 class="topic-title">{$oTalk->getTitle()|escape:'html'}</h1>
		
	</header>


	<div class="topic-content text">
		{$oTalk->getText()}
	</div>
	
	{include file='actions/ActionTalk/speakers.tpl'}


	<footer class="topic-footer">
		<ul class="topic-info">
			<li class="topic-info-author">
				<a href="{$oUser->getUserWebPath()}"><img src="{$oUser->getProfileAvatarPath(24)}"  class="avatar" /></a>
				<a rel="author" href="{$oUser->getUserWebPath()}">{$oUser->getLogin()}</a>
			</li>
			<li class="topic-info-date">
				<time datetime="{date_format date=$oTalk->getDate() format='c'}" pubdate title="{date_format date=$oTalk->getDate() format='j F Y, H:i'}">
					{date_format date=$oTalk->getDate() format="j F Y, H:i"}
				</time>
			</li>
			<li class="topic-info-favourite">
                <div class="favourite {if $oTalk->getIsFavourite()}active{/if}" data-target_id="{$oTalkId}" data-target_type="talk">
                    {if $oTalk->getIsFavourite()}
                        {t}favourite_in{/t}
                    {else}
                        {t}favourite_add{/t}
                    {/if}
                </div>
			</li>
			<li class="delete"><a href="{router page='talk'}delete/{$oTalkId}/?security_ls_key={$LIVESTREET_SECURITY_KEY}" onclick="return confirm('{$aLang.talk_inbox_delete_confirm}');" class="delete">{$aLang.delete}</a></li>
			{hook run='talk_read_info_item' talk=$oTalk}
		</ul>
	</footer>
</article>

{assign var="oTalkUser" value=$oTalk->getTalkUser()}

{if !$bNoComments}
{include
	file='comment_tree.tpl'
	iAuthorId=$oTalk->getUserId()
	sAuthorNotice=$aLang.topic_author
	iTargetId=$oTalkId
	sTargetType='talk'
	iCountComment=$oTalk->getCountComment()
	sDateReadLast=$oTalkUser->getDateLast()
	sNoticeCommentAdd=$aLang.topic_comment_add
	bNoCommentFavourites=true
}
{/if}
			
			
{include file='footer.tpl' scripts=["comments"]}