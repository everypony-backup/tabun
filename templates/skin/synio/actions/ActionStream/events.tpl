{if count($aStreamEvents)}
	{foreach from=$aStreamEvents item=oStreamEvent}		
		{assign var=oTarget value=$oStreamEvent->getTarget()}

		{if {date_format date=$oStreamEvent->getDateAdded() format="j F Y"} != $sDateLast}
			{assign var=sDateLast value={date_format date=$oStreamEvent->getDateAdded() format="j F Y"}}
			
			<li class="stream-header-date">
				{if {date_format date=$smarty.now format="j F Y"} == $sDateLast}
					{$aLang.today}
				{else}
					{date_format date=$oStreamEvent->getDateAdded() format="j F Y"}
				{/if}
			</li>
		{/if}

		{assign var=oUser value=$oStreamEvent->getUser()}

		<li class="stream-item stream-item-type-{$oStreamEvent->getEventType()}">
			<a href="{$oUser->getUserWebPath()}" data-user_id="{$oUser->getId()}"><img src="{$oUser->getProfileAvatarPath(48)}"  class="avatar" /></a>
			
			<p class="info"><a href="{$oUser->getUserWebPath()}"><strong>{$oUser->getLogin()}</strong></a> ·
			<span class="date" title="{date_format date=$oStreamEvent->getDateAdded()}">{date_format date=$oStreamEvent->getDateAdded() hours_back="12" minutes_back="60" now="60" day="day H:i" format="j F Y, H:i"}</span></p>

			{if $oStreamEvent->getEventType() == 'add_topic'}
				{if $oUser->getProfileSex() != 'woman'} {$aLang.stream_list_event_add_topic} {else} {$aLang.stream_list_event_add_topic_female} {/if} 
				<a href="{$oTarget->getUrl()}">{$oTarget->getTitle()|escape:'html'}</a>
			{elseif $oStreamEvent->getEventType() == 'add_comment'}
				{if $oUser->getProfileSex() != 'woman'} {$aLang.stream_list_event_add_comment} {else} {$aLang.stream_list_event_add_comment_female} {/if} 
				<a href="{$oTarget->getTarget()->getUrl()}#comment{$oTarget->getId()}">{$oTarget->getTarget()->getTitle()|escape:'html'}</a>
				{assign var=sTextEvent value=$oTarget->getText()|strip_tags|truncate:200}
				{if trim($sTextEvent)}
					<div class="stream-comment-preview">{$sTextEvent}</div>
				{/if}
			{elseif $oStreamEvent->getEventType() == 'add_blog'}
				{if $oUser->getProfileSex() != 'woman'} {$aLang.stream_list_event_add_blog} {else} {$aLang.stream_list_event_add_blog_female} {/if} 
				<a href="{$oTarget->getUrlFull()}">{$oTarget->getTitle()|escape:'html'}</a>
			{elseif $oStreamEvent->getEventType() == 'vote_blog'}
				{if $oUser->getProfileSex() != 'woman'} {$aLang.stream_list_event_vote_blog} {else} {$aLang.stream_list_event_vote_blog_female} {/if}
				{assign var=oVote value=$oStreamEvent->getVote()}
				{if strtotime($oVote->getDate()) > Config::Get('vote_state.blog.as_date')}
					<span class="stream-voted
					{if $oVote}
						{if $oVote->getDirection() > 0}
							stream-voted-up
						{elseif $oVote->getDirection() < 0}
							stream-voted-down
						{/if}
					{/if}
					">?</span>
				{/if}
				<a href="{$oTarget->getUrlFull()}">{$oTarget->getTitle()|escape:'html'}</a>
			{elseif $oStreamEvent->getEventType() == 'vote_topic'}
				{if $oUser->getProfileSex() != 'woman'} {$aLang.stream_list_event_vote_topic} {else} {$aLang.stream_list_event_vote_topic_female} {/if}
				{assign var=oVote value=$oStreamEvent->getVote()}
				{if strtotime($oVote->getDate()) > Config::Get('vote_state.topic.as_date')}
					<span class="stream-voted
					{if $oVote}
						{if $oVote->getDirection() > 0}
							stream-voted-up
						{elseif $oVote->getDirection() < 0}
							stream-voted-down
						{/if}
					{/if}
					">?</span>
				{/if}
				<a href="{$oTarget->getUrl()}">{$oTarget->getTitle()|escape:'html'}</a>
			{elseif $oStreamEvent->getEventType() == 'vote_comment'}
				{if $oUser->getProfileSex() != 'woman'} {$aLang.stream_list_event_vote_comment} {else} {$aLang.stream_list_event_vote_comment_female} {/if}
				{assign var=oVote value=$oStreamEvent->getVote()}
				{if strtotime($oVote->getDate()) > Config::Get('vote_state.comment.as_date')}
					<span class="stream-voted
					{if $oVote}
						{if $oVote->getDirection() > 0}
							stream-voted-up
						{elseif $oVote->getDirection() < 0}
							stream-voted-down
						{/if}
					{/if}
					">?</span>
				{/if}
				<a href="{$oTarget->getTarget()->getUrl()}#comment{$oTarget->getId()}">{$oTarget->getTarget()->getTitle()|escape:'html'}</a>
			{elseif $oStreamEvent->getEventType() == 'vote_user'}
				{if $oUser->getProfileSex() != 'woman'} {$aLang.stream_list_event_vote_user} {else} {$aLang.stream_list_event_vote_user_female} {/if}
				{assign var=oVote value=$oStreamEvent->getVote()}
				{if strtotime($oVote->getDate()) > Config::Get('vote_state.user.as_date')}
					<span class="stream-voted
					{if $oVote}
						{if $oVote->getDirection() > 0}
							stream-voted-up
						{elseif $oVote->getDirection() < 0}
							stream-voted-down
						{/if}
					{/if}
					">?</span>
				{/if}
				<span class="user-avatar user-avatar-n">
					<a href="{$oTarget->getUserWebPath()}"><img src="{$oTarget->getProfileAvatarPath(24)}"  /></a>
					<a href="{$oTarget->getUserWebPath()}">{$oTarget->getLogin()}</a>
				</span>
			{elseif $oStreamEvent->getEventType() == 'join_blog'}
				{if $oUser->getProfileSex() != 'woman'} {$aLang.stream_list_event_join_blog} {else} {$aLang.stream_list_event_join_blog_female} {/if} 
				<a href="{$oTarget->getUrlFull()}">{$oTarget->getTitle()|escape:'html'}</a>
			{elseif $oStreamEvent->getEventType() == 'add_friend'}
				{if $oUser->getProfileSex() != 'woman'} {$aLang.stream_list_event_add_friend} {else} {$aLang.stream_list_event_add_friend_female} {/if}
				<span class="user-avatar user-avatar-n">
					<a href="{$oTarget->getUserWebPath()}"><img src="{$oTarget->getProfileAvatarPath(24)}"  /></a>
					<a href="{$oTarget->getUserWebPath()}">{$oTarget->getLogin()}</a>
				</span>
			{else}
				{hook run="stream_list_event_`$oStreamEvent->getEventType()`" oStreamEvent=$oStreamEvent}
			{/if}
		</li>
	{/foreach}
{/if}
