{include file='header.tpl'}


{include file='menu.settings.tpl'}


{hook run='settings_tuning_begin'}

<form action="{router page='settings'}tuning/" method="POST" enctype="multipart/form-data" class="wrapper-content">
	{hook run='form_settings_tuning_begin'}

	<input type="hidden" name="security_ls_key" value="{$LIVESTREET_SECURITY_KEY}" />
	
	<h3>{$aLang.settings_tuning_notice}</h3>

	<label><input {if $oUserCurrent->getSettingsNoticeNewTopic()}checked{/if} type="checkbox" id="settings_notice_new_topic" name="settings_notice_new_topic" value="1" class="input-checkbox" /> {$aLang.settings_tuning_notice_new_topic}</label>
	<label><input {if $oUserCurrent->getSettingsNoticeNewComment()}checked{/if} type="checkbox" id="settings_notice_new_comment" name="settings_notice_new_comment" value="1" class="input-checkbox" /> {$aLang.settings_tuning_notice_new_comment}</label>
	<label><input {if $oUserCurrent->getSettingsNoticeNewTalk()}checked{/if} type="checkbox" id="settings_notice_new_talk" name="settings_notice_new_talk" value="1" class="input-checkbox" /> {$aLang.settings_tuning_notice_new_talk}</label>
	<label><input {if $oUserCurrent->getSettingsNoticeReplyComment()}checked{/if} type="checkbox" id="settings_notice_reply_comment" name="settings_notice_reply_comment" value="1" class="input-checkbox" /> {$aLang.settings_tuning_notice_reply_comment}</label>
	<label><input {if $oUserCurrent->getSettingsNoticeNewFriend()}checked{/if} type="checkbox" id="settings_notice_new_friend" name="settings_notice_new_friend" value="1" class="input-checkbox" /> {$aLang.settings_tuning_notice_new_friend}</label>

	<br />
	<h3>{$aLang.settings_tuning_general}</h3>
	<label>{$aLang.settings_tuning_general_timezone}:
		<select name="settings_general_timezone" class="input-width-400">
			{foreach from=$aTimezoneList item=sTimezone}
				<option value="{$sTimezone}" {if $_aRequest.settings_general_timezone==$sTimezone}selected="selected"{/if}>{$aLang.timezone_list[$sTimezone]}</option>
			{/foreach}
		</select>
	</label>

	<br />
	<h3>Настройки интерфейса</h3>
	<label>
		<input type="checkbox" onclick="window.localStorage.setItem(this.id, this.checked)" id="UI-smothScroll"/>
		Плавная анимация прокрутки
	</label>
	<label title="'space' или 'ins' - переход к следующему новому комментарию; 'enter' или 'del' обновить комментарии">
		<input type="checkbox" onclick="window.localStorage.setItem(this.id, this.checked)" id="UI-hotkeys"/>
		Горячие клавиши
	</label>
	<label>
		<input type="checkbox" onclick="window.localStorage.setItem(this.id, this.checked)" id="UI-smartQuote"/>
		Умное цитирование
	</label>
	<label>
		<input type="checkbox" onclick="window.localStorage.setItem(this.id, this.checked)" id="UI-autoFold"/>
		Автосворачивание промежуточных комментариев
	</label>
	<label>
		<input type="checkbox" onclick="window.localStorage.setItem(this.id, this.checked)" id="UI-newCommentsInTitle"/>
		Отображать количество новых комментариев в заголовке
	</label>
	<label>
		<input type="checkbox" onclick="window.localStorage.setItem(this.id, this.checked)" id="UI-autoUpdateComments"/>
		Автообновление комментариев
	</label>
	<label>
		<input type="checkbox" onclick="window.localStorage.setItem(this.id, this.checked)" id="UI-autoDespoil"/>
		Раскрывать спойлеры в активном комментарии
	</label>
	<label>
		<input type="checkbox" onclick="window.localStorage.setItem(this.id, this.checked)" id="UI-despoilOnlyArticle"/>
		Кнопка "Despoil" действует только на топик
	</label>

	<script type="text/javascript">
		document.getElementById("UI-smothScroll").checked = UI.smothScroll;
		document.getElementById("UI-hotkeys").checked = UI.hotkeys;
		document.getElementById("UI-smartQuote").checked = UI.smartQuote;
		document.getElementById("UI-autoFold").checked = UI.autoFold;
		document.getElementById("UI-newCommentsInTitle").checked = UI.newCommentsInTitle;
		document.getElementById("UI-autoUpdateComments").checked = UI.autoUpdateComments;
		document.getElementById("UI-autoDespoil").checked = UI.autoDespoil;
		document.getElementById("UI-despoilOnlyArticle").checked = UI.despoilOnlyArticle;
	</script>

	{hook run='form_settings_tuning_end'}
	<br />
	<button type="submit" name="submit_settings_tuning" class="button button-primary">{$aLang.settings_profile_submit}</button>
</form>

{hook run='settings_tuning_end'}

{include file='footer.tpl'}