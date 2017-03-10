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
	<label title="Отключите эту опцию если у вас тормозит анимация">
		<input type="checkbox" class="UI-checkbox" data-name="smothScroll"/>
		Плавная анимация прокрутки
	</label>
	<label title="'space' или 'ins' - переход к следующему новому комментарию; 'enter' или 'del' обновить комментарии">
		<input type="checkbox" class="UI-checkbox" data-name="hotkeys"/>
		Горячие клавиши
	</label>
	<label title="Всплывающее окошко предлагающее процитировать выделенный фрагмент">
		<input type="checkbox" class="UI-checkbox" data-name="smartQuote"/>
		Умное цитирование
	</label>
	<label title="Будут сворачиваться все комменты между активным комментарием и его родителем">
		<input type="checkbox" class="UI-checkbox" data-name="autoFold"/>
		Автосворачивание промежуточных комментариев
	</label>
	<label title="Отображать количество новых комментариев в заголовке">
		<input type="checkbox" class="UI-checkbox" data-name="newCommentsInTitle"/>
		Отображать количество новых комментариев в заголовке
	</label>
	<label title="В фоновых вкладках комментарии будут автоматически обнавляться раз в минуту">
		<input type="checkbox" class="UI-checkbox" data-name="autoUpdateComments"/>
		Автообновление комментариев
	</label>
	<label title="При переходе к новому комментарию все спойлеры будут автоматически развёрнуты, а грей-спойлеры подсвечены">
		<input type="checkbox" class="UI-checkbox" data-name="autoDespoil"/>
		Раскрывать спойлеры в активном комментарии
	</label>
	<label title="Отключите эту опцию чтобы кнопка Despoil не влияла на комментарии">
		<input type="checkbox" class="UI-checkbox" data-name="despoilOnlyArticle"/>
		Кнопка "Despoil" действует только на топик
	</label>
	<label title="Для особо пугливых">
		<input type="checkbox" class="UI-checkbox" data-name="showPinkie"/>
		Пинкамина
	</label>
	<label title="Позволяет отключить нейтральное голосование за топики">
		<input type="checkbox" class="UI-checkbox" data-name="voteNeutral"/>
		Нейтрально голосовать за топики по *?*
	</label>
	<label>Задержите курсор мышки над опцией чтобы увидеть более подробное описание</label>

	{hook run='form_settings_tuning_end'}
	<br />
	<button type="submit" name="submit_settings_tuning" class="button button-primary">{$aLang.settings_profile_submit}</button>
</form>

{hook run='settings_tuning_end'}

{include file='footer.tpl'}