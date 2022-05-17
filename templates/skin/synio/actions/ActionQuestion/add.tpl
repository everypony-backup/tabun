{include file='header.tpl'}
{assign var="scripts" value=['editor']}

{if $sEvent=='add'}
    <div data-bazooka="topictype_selector"></div>
{else}
	<h2 class="page-header">{$aLang.topic_question_edit}</h2>
{/if}


{include file='editor.tpl'}

<form action="" method="POST" enctype="multipart/form-data" id="form-topic-add" class="wrapper-content">
	<input type="hidden" name="security_ls_key" value="{$LIVESTREET_SECURITY_KEY}" />

	<p><label for="blog_id">{$aLang.topic_create_blog}</label>
	<select name="blog_id" id="blog_id" class="input-width-full">
		<option value="0">{$aLang.topic_create_blog_personal}</option>
		{foreach from=$aBlogsAllow item=oBlog}
			<option value="{$oBlog->getId()}" {if $_aRequest.blog_id==$oBlog->getId()}selected{/if}>{$oBlog->getTitle()|escape:'html'}</option>
		{/foreach}
	</select>
	<small class="note">{$aLang.topic_create_blog_notice}</small></p>

	<p><label for="topic_title">{$aLang.topic_question_create_title}:</label>
	<input type="text" id="topic_title" name="topic_title" value="{$_aRequest.topic_title}" class="input-text input-width-full" {if $bEditDisabled}readonly="readonly"{/if} /><br />
	<small class="note">{$aLang.topic_question_create_title_notice}</small></p>

	<div class="poll-create">
		<label>{$aLang.topic_question_create_answers}:</label>
		<ul class="question-list" id="question_list">
			{if $_aRequest.answer && count($_aRequest.answer) >=2}
				{foreach from=$_aRequest.answer item=sAnswer key=i}
					<li>
						<input type="text" value="{$sAnswer}" name="answer[]" class="input-text input-width-300" {if $bEditDisabled}disabled{/if} />
						{if !$bEditDisabled and $i>1} <a class="icon-synio-remove"></a>{/if}
					</li>
				{/foreach}
			{else}
				<li><input type="text" value="" name="answer[]" class="input-text input-width-300" {if $bEditDisabled}disabled{/if} /></li>
				<li><input type="text" value="" name="answer[]" class="input-text input-width-300" {if $bEditDisabled}disabled{/if} /></li>
			{/if}
		</ul>
	
		{if !$bEditDisabled}
			<a class="link-dotted">{$aLang.topic_question_create_answers_add}</a>
		{/if}
	</div>

	<p><label for="topic_text">{$aLang.topic_question_create_text}:</label>
	<textarea name="topic_text" id="topic_text" rows="10" class="input-width-full markitup-editor input-width-full">{$_aRequest.topic_text}</textarea>
	{include file='tags_help.tpl' sTagsTargetId="topic_text"}
	</p>
		
	<p><label for="topic_tags">{$aLang.topic_create_tags}:</label>
	<input type="text" id="topic_tags" name="topic_tags" value="{$_aRequest.topic_tags}" class="input-text input-width-full autocomplete-tags-sep" />
	<small class="note">{$aLang.topic_create_tags_notice}</small></p>

	<p><label for="topic_forbid_comment">
	<input type="checkbox" id="topic_forbid_comment" name="topic_forbid_comment" class="input-checkbox" value="1" {if $_aRequest.topic_forbid_comment==1}checked{/if} />
	{$aLang.topic_create_forbid_comment}</label>
	<small class="note">{$aLang.topic_create_forbid_comment_notice}</small></p>

	{if $oUserCurrent->isAdministrator()}
		<p><label for="topic_publish_index">
		<input type="checkbox" id="topic_publish_index" name="topic_publish_index" class="input-checkbox" value="1" {if $_aRequest.topic_publish_index==1}checked{/if} />
		{$aLang.topic_create_publish_index}</label>
		<small class="note">{$aLang.topic_create_publish_index_notice}</small></p>
	{/if}

	<input type="hidden" name="topic_type" value="question" />

	<button type="submit"  name="submit_topic_publish" id="submit_topic_publish" class="h-hidden button button-primary h-float-right">{$aLang.topic_create_submit_publish}</button>
	<button  id="fake_publish" data-target="submit_topic_publish" class="button button-primary h-float-right">{$aLang.topic_create_submit_publish}</button>
	<button type="submit"  name="submit_preview" class="button submit-preview">{$aLang.topic_create_submit_preview}</button>
	<button type="submit"  name="submit_topic_save" id="submit_topic_save" class="button h-hidden">{$aLang.topic_create_submit_save}</button>
	<button id="fake_save" data-target="submit_topic_save" class="button">{$aLang.topic_create_submit_save}</button>
</form>

<div class="topic-preview" id="text_preview"></div>


{include file='footer.tpl' scripts=$scripts}
