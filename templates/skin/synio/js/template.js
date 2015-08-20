jQuery(document).ready(function($){

	toolbarPos();

	$(window).resize(function(){
		toolbarPos();
	});

	$(window).scroll(function(){
		if ($(document).width() <= 1100) {
			toolbarPos();
		}
	});

	// комментарии
	ls.comments.init();

	// Help-tags link
	$('.js-tags-help-link').click(function(){
		var target=ls.tools.registry.get('tags-help-target-id');
		if (!target || !$('#'+target).length) {
			return false;
		}
		target=$('#'+target);
		if ($(this).data('insert')) {
			var s=$(this).data('insert');
		} else {
			var s=$(this).text();
		}
		$.markItUp({target: target, replaceWith: s});
		return false;
	});


	// Фикс бага с z-index у встроенных видео
	$("iframe").each(function(){
		var ifr_source = $(this).attr('src');

		if(ifr_source) {
			var wmode = "wmode=opaque";

			if (ifr_source.indexOf('?') != -1)
				$(this).attr('src',ifr_source+'&'+wmode);
			else
				$(this).attr('src',ifr_source+'?'+wmode);
		}
	});

	// Инициализация строчки поиска
	(function(){
		var search_show = $('#search-header-show');
		if (!search_show.length) {
			return;
		}
		var search_form = $('#search-header-form');
		var write 		= $('#modal_write_show');

		search_show.click(function(){
			search_form.toggle().find('.input-text').focus();
			$(this).toggle();
			write.toggle();
			return false;
		});

		$(document).click(function(){
			if (search_form.find('.input-text').val() == '') {
				search_form.hide();
				search_show.show();
				write.show();
			}
		});

		$('body').on('click', '#search-header-form', function(e) {
			e.stopPropagation();
		});
	})();
});


function toolbarPos() {
	var $=jQuery;
	if ($('#toolbar section').length) {
		if ($(document).width() <= 1100) {
			if (!$('#container').hasClass('no-resize')) {
				$('#container').addClass('toolbar-margin');
			}
			$('#toolbar').css({'position': 'absolute', 'right': 0, 'top' : $(document).scrollTop() + 175, 'display': 'block'});
		} else {
			$('#container').removeClass('toolbar-margin');
			$('#toolbar').css({'position': 'fixed', 'right': 0, 'top': 175, 'display': 'block'});
		}
	}
};

