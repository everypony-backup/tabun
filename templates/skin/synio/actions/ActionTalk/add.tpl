{include file='header.tpl'}
{assign var="scripts" value=['editor']}

{include file='menu.talk.tpl'}

{include file='actions/ActionTalk/friends.tpl'}

<div class="topic" style="display: none;">
	<div class="content" id="text_preview"></div>
</div>

{include file='editor.tpl' sImgToLoad='talk_text' sSettingsMarkitup='ls.settings.getMarkitupComment()'}

<form action="" method="POST" enctype="multipart/form-data">

	<input type="hidden" name="security_ls_key" value="{$LIVESTREET_SECURITY_KEY}" />

	<p><label for="talk_users">{$aLang.talk_create_users}:</label>
	<input type="text" class="input-text input-width-full autocomplete-users-sep" id="talk_users" name="talk_users" value="{$_aRequest.talk_users}" /></p>

	<p><label for="talk_title">{$aLang.talk_create_title}:</label>
	<input type="text" class="input-text input-width-full" id="talk_title" name="talk_title" value="{$_aRequest.talk_title}" /></p>

	<p><label for="talk_text">{$aLang.talk_create_text}:</label>
	<textarea name="talk_text" id="talk_text" rows="12" class="input-text input-width-full markitup-editor input-width-full">{$_aRequest.talk_text}</textarea></p>

	<button type="submit" class="h-hidden button button-primary" id="submit_talk_add" name="submit_talk_add">{$aLang.talk_create_submit}</button>
	<button class="button button-primary" id="fake_talk_add" data-target="">{$aLang.talk_create_submit}</button>
	<button type="submit" class="button" id="talk_preview" name="submit_preview">{$aLang.topic_create_submit_preview}</button>
</form>


{include file='footer.tpl' scripts=$scripts}
