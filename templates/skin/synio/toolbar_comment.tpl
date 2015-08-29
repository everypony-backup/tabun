{if $oUserCurrent}
	<section class="toolbar-update" id="update">
		<a href="#" class="update-comments" id="update-comments" onclick="ls.comments.load({$params.iTargetId},'{$params.sTargetType}'); return false;"><i></i></a>
		<div class="new-comments h-hidden" id="new_comments_counter" data-id-comment-last="{$params.iMaxIdComment}" title="{$aLang.comment_count_new}" onclick="ls.comments.goToNextComment(); return false;"></div>
	</section>
{/if}
