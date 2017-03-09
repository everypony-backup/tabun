{hook run='profile_sidebar_begin' oUserProfile=$oUserProfile}

<section class="block block-type-profile-nav">
	<ul class="nav nav-profile">
		{hook run='profile_sidebar_menu_item_first' oUserProfile=$oUserProfile}
		<li {if $sAction=='profile' && ($aParams[0]=='whois' or $aParams[0]=='')}class="active"{/if}><a href="{$oUserProfile->getUserWebPath()}">{$aLang.user_menu_profile_whois}</a></li>
		<li {if $sAction=='profile' && $aParams[0]=='created'}class="active"{/if}><a href="{$oUserProfile->getUserWebPath()}created/topics/">{$aLang.user_menu_publication}{if ($iCountCreated)>0} ({$iCountCreated}){/if}</a></li>
		<li {if $sAction=='profile' && $aParams[0]=='favourites'}class="active"{/if}><a href="{$oUserProfile->getUserWebPath()}favourites/topics/">{$aLang.user_menu_profile_favourites}{if ($iCountFavourite)>0} ({$iCountFavourite}){/if}</a></li>
		<li {if $sAction=='profile' && $aParams[0]=='friends'}class="active"{/if}><a href="{$oUserProfile->getUserWebPath()}friends/">{$aLang.user_menu_profile_friends}{if ($iCountFriendsUser)>0} ({$iCountFriendsUser}){/if}</a></li>
		<li {if $sAction=='profile' && $aParams[0]=='stream'}class="active"{/if}><a href="{$oUserProfile->getUserWebPath()}stream/">{$aLang.user_menu_profile_stream}</a></li>
		{hook run='profile_sidebar_menu_item_last' oUserProfile=$oUserProfile}
	</ul>
</section>

<section class="block block-type-profile">
	<div class="profile-photo-wrapper">
		<a href="{$oUserProfile->getUserWebPath()}"><img src="{$oUserProfile->getProfileFotoPath()}"  class="profile-photo" id="foto-img" /></a>
	</div>

	{if $sAction=='settings' and $oUserCurrent and $oUserCurrent->getId() == $oUserProfile->getId()}

		<p class="upload-photo">
			<a href="#" id="foto-upload" class="link-dotted">{if $oUserCurrent->getProfileFoto()}{$aLang.settings_profile_photo_change}{else}{$aLang.settings_profile_photo_upload}{/if}</a>&nbsp;&nbsp;&nbsp;
			<a href="#" id="foto-remove" class="link-dotted" style="{if !$oUserCurrent->getProfileFoto()}display:none;{/if}">{$aLang.settings_profile_foto_delete}</a>
		</p>

		<div class="modal modal-upload-photo" id="foto-resize">
			<header class="modal-header">
				<h3>{$aLang.settings_profile_avatar_resize_title}</h3>
			</header>

			<div class="modal-content">
				<div class="clearfix">
					<div class="image-border">
						<img src=""  id="foto-resize-original-img">
					</div>
				</div>

				<button type="submit" id="foto-resize-button" class="button button-primary">{$aLang.settings_profile_avatar_resize_apply}</button>
				<button type="submit" id="foto-cancel-button" class="button">{$aLang.settings_profile_avatar_resize_cancel}</button>
			</div>
		</div>
	{/if}
</section>

{hook run='profile_sidebar_menu_before' oUserProfile=$oUserProfile}
{hook run='profile_sidebar_end' oUserProfile=$oUserProfile}

{if $oUserCurrent && $oUserCurrent->getId() != $oUserProfile->getId()}
	<section class="block block-type-profile-note">
		<div id="usernote-note" class="profile-note" {if !$oUserNote}style="display: none;"{/if}>
			<p id="usernote-note-text">
				{if $oUserNote}
					{$oUserNote->getText()}
				{/if}
			</p>

			<ul class="actions">
				<li><a id="usernote_edit" class="link-dotted">{$aLang.user_note_form_edit}</a></li>
				<li><a id="usernote_delete" data-user_id="{$oUserProfile->getId()}" class="link-dotted">{$aLang.user_note_form_delete}</a></li>
			</ul>
		</div>

		<div id="usernote-form" style="display: none;">
			<p><textarea rows="4" cols="20" id="usernote-form-text" class="input-text input-width-full"></textarea></p>
			<button type="submit" id="usernote_save" data-user_id="{$oUserProfile->getId()}" class="button button-primary">{$aLang.user_note_form_save}</button>
			<button type="submit" id="usernote_cancel" class="button">{$aLang.user_note_form_cancel}</button>
		</div>

		<a id="usernote-button-add" class="link-dotted" {if $oUserNote}style="display:none;"{/if}>{$aLang.user_note_add}</a>
	</section>
{/if}

{if $oUserCurrent && $oUserCurrent->getId()!=$oUserProfile->getId()}
	<section class="block block-type-profile-actions">
		<div class="block-content">
			<ul class="profile-actions" id="profile_actions">
				{include file='actions/ActionProfile/friend_item.tpl' oUserFriend=$oUserProfile->getUserFriend()}
				<li><a href="{router page='talk'}add/?talk_users={$oUserProfile->getLogin()}">{$aLang.user_write_prvmsg}</a></li>
				<li>
					<a href="#" id="follow_user" data-user_id="{$oUserProfile->getId()}" class="{if $oUserProfile->isFollow()}followed{/if}">
						{if $oUserProfile->isFollow()}{$aLang.profile_user_unfollow}{else}{$aLang.profile_user_follow}{/if}
					</a>
				</li>
			</ul>
		</div>
	</section>
{/if}
