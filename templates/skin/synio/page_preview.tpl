<h3 class="profile-page-header">{$aLang.topic_preview}</h3>

<h2 class="page-header">{$oPage->getTitle()|escape}</h2>

{$oPage->getText()}

<button type="submit"  name="submit_page_publish" class="button button-primary h-float-right" onclick="jQuery('#submit_page_publish').trigger('click');">{$aLang.topic_create_submit_publish}</button>
<button type="submit"  name="submit_preview" onclick="jQuery('#text_preview').html('').hide(); return false;" class="button">{$aLang.topic_create_submit_preview_close}</button>
