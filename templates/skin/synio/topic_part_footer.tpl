	{assign var="oBlog" value=$oTopic->getBlog()}
	{assign var="oUser" value=$oTopic->getUser()}
	{assign var="oVote" value=$oTopic->getVote()}
	{assign var="oFavourite" value=$oTopic->getFavourite()}


	<footer class="topic-footer">
		<p class="topic-tags js-favourite-insert-after-form js-favourite-tags-topic-{$oTopic->getId()}">
		Теги: 
			{strip}
				{if $oTopic->getTagsArray()}
					{foreach from=$oTopic->getTagsArray() item=sTag name=tags_list}
						{if !$smarty.foreach.tags_list.first}, {/if}<a rel="tag" href="{router page='search'}?q={$sTag|escape:'url'}&coded=tsdfft">{$sTag|escape:'html'}</a>
					{/foreach}
				{else}
					{$aLang.topic_tags_empty}
				{/if}
				
				{if $oUserCurrent}
					{if $oFavourite}
						{foreach from=$oFavourite->getTagsArray() item=sTag name=tags_list_user}
							<span class="topic-tags-user js-favourite-tag-user">, <a rel="tag" href="{$oUserCurrent->getUserWebPath()}favourites/topics/tag/{$sTag|escape:'url'}/">{$sTag|escape:'html'}</a></span>
						{/foreach}
					{/if}
					
					<span class="topic-tags-edit js-favourite-tag-edit" {if !$oFavourite}style="display:none;"{/if}>
						<a href="#" onclick="return ls.favourite.showEditTags({$oTopic->getId()},'topic',this);" class="link-dotted">{$aLang.favourite_form_tags_button_show}</a>
					</span>
				{/if}
			{/strip}
		</p>

		<ul class="topic-info">
			<li class="topic-info-date">
				<time datetime="{date_format date=$oTopic->getDateAdd() format='c'}" title="{date_format date=$oTopic->getDateAdd() hours_back="12" minutes_back="60" now="60" day="day H:i" format="j F Y, H:i"}">
					{date_format date=$oTopic->getDateAdd() format='j F Y, H:i'}
				</time>
			</li>
			<li class="topic-info-favourite>
				<div class="favourite {if $oUserCurrent && $oTopic->getIsFavourite()}active{/if}" onclick="return ls.favourite.toggle({$oTopic->getId()},this,'topic');">{if $oTopic->getIsFavourite()}{t}favourite_in{/t}{else}{t}favourite_add{/t}{/if}</div>
				<span class="favourite-count" id="fav_count_topic_{$oTopic->getId()}">{if $oTopic->getCountFavourite() > 0}{$oTopic->getCountFavourite()}{/if}</span>
			</li>

			{if $bTopicList}
				<li class="topic-info-comments">
					{if $oTopic->getCountCommentNew()}
						<a href="{$oTopic->getUrl()}#comments" title="{$aLang.topic_comment_read}" class="new">
							<i class="icon-synio-comments-green-filled"></i>
							<span>{$oTopic->getCountComment()}</span>
							<span class="count">+{$oTopic->getCountCommentNew()}</span>
						</a>
					{else}
						<a href="{$oTopic->getUrl()}#comments" title="{$aLang.topic_comment_read}">
							{if $oTopic->getCountComment()}
								<i class="icon-synio-comments-green-filled"></i>
							{else}
								<i class="icon-synio-comments-blue"></i>
							{/if}
							
							<span>{$oTopic->getCountComment()}</span>
						</a>
					{/if}
				</li>
			{/if}


			{if $oVote || ($oUserCurrent && $oTopic->getUserId() == $oUserCurrent->getId()) || strtotime($oTopic->getDateAdd()) < $smarty.now-$oConfig->GetValue('acl.vote.topic.limit_time')}
				{assign var="bVoteInfoShow" value=true}
			{/if}
			
			{hook run='topic_show_info' topic=$oTopic}
		</ul>

		
		{if !$bTopicList}
			{hook run='topic_show_end' topic=$oTopic}
		{/if}
	</footer>
</article> <!-- /.topic -->
