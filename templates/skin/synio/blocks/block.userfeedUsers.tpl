{if $oUserCurrent}
	<section class="block block-type-activity">
		<header class="block-header">
			<h3>{$aLang.userfeed_block_users_title}</h3>
		</header>
		
		<div class="block-content">
			<small class="note">{$aLang.userfeed_settings_note_follow_user}</small>
			
			<div class="stream-settings-userlist">
				<div class="search-form-wrapper">
					<div class="search-input-wrapper">
						<input type="text" id="userfeed_users_complete" autocomplete="off" placeholder="{$aLang.userfeed_block_users_append}" class="autocomplete-users input-text input-width-full" />
						<div class="input-submit"></div>
					</div>
				</div>
				
				{if count($aUserfeedSubscribedUsers)}
					<ul id="userfeed_block_users_list" class="user-list-mini max-height-200">
						{foreach from=$aUserfeedSubscribedUsers item=oUser}
							{assign var=iUserId value=$oUser->getId()}
							
							{if !isset($aUserfeedFriends.$iUserId)}
								<li><input class="userfeedUserCheckbox input-checkbox" type="checkbox" id="usf_u_{$iUserId}" {if isset($aUserfeedSubscribedUsers.$iUserId)} checked="checked"{/if} data-user_id="{$iUserId}"/>
									<a href="{$oUser->getUserWebPath()}" title="{$oUser->getLogin()}"><img src="{$oUser->getProfileAvatarPath(24)}"  class="avatar" /></a>
									<a href="{$oUser->getUserWebPath()}">{$oUser->getLogin()}</a>
								</li>
							{/if}
						{/foreach}
					 </ul>
				{else}
					<ul id="userfeed_block_users_list"></ul>
				{/if}
			</div>
		</div>
	</section>
	
	
	{if count($aUserfeedFriends)}
		<section class="block block-type-activity">
			<header class="block-header">
				<h3>{$aLang.userfeed_block_users_friends}</h3>
			</header>
			
			<div class="block-content">
				<small class="note">{$aLang.userfeed_settings_note_follow_friend}</small>
				
				<ul class="user-list-mini stream-settings-friends max-height-200">
					{foreach from=$aUserfeedFriends item=oUser}
						{assign var=iUserId value=$oUser->getId()}
						
						<li><input class="userfeedUserCheckbox input-checkbox" type="checkbox" id="usf_u_{$iUserId}" {if isset($aUserfeedSubscribedUsers.$iUserId)} checked="checked"{/if} data-user_id="{$iUserId}"/>
							<a href="{$oUser->getUserWebPath()}" title="{$oUser->getLogin()}"><img src="{$oUser->getProfileAvatarPath(24)}"  class="avatar" /></a>
							<a href="{$oUser->getUserWebPath()}">{$oUser->getLogin()}</a>
						</li>
					{/foreach}
				</ul>
			</div>
		</section>
	{/if}
{/if}
