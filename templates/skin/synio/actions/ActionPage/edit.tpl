{assign var="noSidebar" value=true}
{include file='header.tpl'}
{assign var="scripts" value=['editor']}

{block name='layout_options' prepend}
    {$layoutNoSidebar = !Config::Get('page.show_block_structure')}
{/block}

{include file='editor.tpl'}

<form action="" method="POST" enctype="multipart/form-data" id="form-page-edit" class="wrapper-content">
    <input type="hidden" name="security_ls_key" value="{$LIVESTREET_SECURITY_KEY}" />

    <p><label for="page_title">{$aLang.topic_create_title}:</label>
        <input type="text" id="page_title" name="page_title" value="{$_aRequest.page_title}" class="input-text input-width-full" /></p>

    <p><label for="page_text">{$aLang.topic_create_text}:</label>
        <textarea name="page_text" id="page_text" class="markitup-editor input-width-full" rows="20">{$_aRequest.page_text}</textarea></p>

    {include file='tags_help.tpl' sTagsTargetId="topic_text"}
    <br />
    <br />

    <button type="submit"  name="submit_page_publish" id="submit_page_publish" class="h-hidden button button-primary h-float-right">{$aLang.topic_create_submit_publish}</button>
    <button  id="fake_publish" data-target="submit_page_publish" class="button button-primary h-float-right">{$aLang.topic_create_submit_publish}</button>
    <button type="submit"  name="submit_preview" class="button submit-preview">{$aLang.topic_create_submit_preview}</button>
</form>


<div class="page-preview" style="display: none;" id="text_preview"></div>

{include file='footer.tpl' scripts=$scripts}
