{if $oUserCurrent}
	<section class="toolbar-update" id="update">
		<i class="update-comments" id="update-comments" data-target_id="{$params.iTargetId}" data-target_type="{$params.sTargetType}"></i>
		<div class="new-comments h-hidden" id="new_comments_counter" data-id-comment-last="{$params.iMaxIdComment}" title="{$aLang.comment_count_new}"></div>
	</section>
{/if}
