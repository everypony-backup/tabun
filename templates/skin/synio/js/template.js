jQuery(document).ready(function($){

	// Скролл
	$(window)._scrollable();


	// Тул-бар топиков
	ls.toolbar.topic.init();
	// Кнопка "UP"
	ls.toolbar.up.init();




	toolbarPos();

	$(window).resize(function(){
		toolbarPos();
	});

	$(window).scroll(function(){
		if ($(document).width() <= 1100) {
			toolbarPos();
		}
	});


	// Всплывающие сообщения
	if (ls.tools.registry.get('block_stream_show_tip')) {
		$('.js-title-comment, .js-title-topic').poshytip({
			className: 'infobox-yellow',
			alignTo: 'target',
			alignX: 'left',
			alignY: 'center',
			offsetX: 10,
			liveEvents: true,
			showTimeout: 1000
		});
	}

	$('.js-infobox-vote-topic').poshytip({
		content: function() {
			var id = $(this).attr('id').replace('vote_area_topic_','vote-info-topic-');
			return $('#'+id).html();
		},
		className: 'infobox-topic',
		alignTo: 'target',
		alignX: 'center',
		alignY: 'top',
		offsetX: 2,
		offsetY: 5,
		liveEvents: true,
		showTimeout: 100
	});

	$('.js-tip-help').poshytip({
		className: 'infobox-standart',
		alignTo: 'target',
		alignX: 'right',
		alignY: 'center',
		offsetX: 5,
		liveEvents: true,
		showTimeout: 500
	});

	$('.js-infobox').poshytip({
		className: 'infobox-topic',
		alignTo: 'target',
		alignX: 'center',
		alignY: 'top',
		offsetY: 5,
		liveEvents: true,
		showTimeout: 300
	});

	// комментарии
	ls.comments.init();

	// лента активности
	ls.hook.add('ls_stream_append_user_after',function(length,data){
		if (length==0) {
			$('#strm_u_'+data.uid).parent().find('a').before('<a href="'+data.user_web_path+'"><img src="'+data.user_avatar_48+'"  class="avatar" /></a> ');
		}
	});

	// регистрация
	ls.hook.add('ls_user_validate_registration_fields_after',function(aFields, sForm, result){
		$.each(aFields,function(i,aField){
			if (result.aErrors && result.aErrors[aField.field][0]) {
				sForm.find('.form-item-help-'+aField.field).removeClass('active');
			} else {
				sForm.find('.form-item-help-'+aField.field).addClass('active');
			}
		});
	});





	/****************
	 * DROPDOWN
	 */
	var nav_pills_dropdown = $('.nav-pills-dropdown');

	nav_pills_dropdown.each(function(i) {
		var obj 	= $(this);
		var menu 	= obj.clone();

		obj.find('li:not(.active)').remove();
		obj.show();

		var timestamp 	= new Date().getTime();
		var active 		= $(this).find('li.active');
		var pos 		= active.offset();

		menu.removeClass().addClass('dropdown-menu').attr('id', 'dropdown-menu-' + timestamp).hide().appendTo('body').css({ 'left': pos.left - 10, 'top': pos.top + 24, 'display': 'none' });
		active.addClass('dropdown').attr('id', 'dropdown-trigger-' + timestamp).append('<i class="icon-synio-arrows"></i>');

		active.click(function(){
			menu.slideToggle();
			return false;
		});
	});

	$(window).resize(function(){
		nav_pills_dropdown.each(function(i) {
			var obj 		= $(this).find('li');
			var timestamp 	= obj.attr('id').replace('dropdown-trigger-', '');
			var pos 		= obj.offset();

			$('#dropdown-menu-' + timestamp).css({ 'left': pos.left + 2 });
		});
	});

	// Hide menu
	$(document).click(function(){
		$('.dropdown-menu').hide();
	});

	$('body').on("click", ".dropdown-menu", function(e) {
		e.stopPropagation();
	});


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

	ls.blog.toggleInfo = function() {
		if ($('#blog-mini').is(':visible')) {
			$('#blog-mini').hide();
			$('#blog').show();
		} else {
			$('#blog-mini').show();
			$('#blog').hide();
		}

		return false;
	};


	ls.infobox.aOptDef=$.extend(true,ls.infobox.aOptDef,{
		className: 'infobox-help',
		offsetX: -16
	});
	//ls.infobox.sTemplateProcess=['<div class="infobox-process"><img src="'+DIR_STATIC_SKIN+'/images/loader-circle.gif" />', '</div>'].join('');
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

