Function.prototype.bind = function(context) {
	var fn = this;
	if(jQuery.type(fn) != 'function'){
		throw new TypeError('Function.prototype.bind: call on non-function');
	};
	if(jQuery.type(context) == 'null'){
		throw new TypeError('Function.prototype.bind: cant be bound to null');
	};
	return function() {
		return fn.apply(context, arguments);
	};
};
String.prototype.tr = function(a,p) {
	var k;
	var p = typeof(p)=='string' ? p : '';
	var s = this;
	jQuery.each(a,function(k){
		var tk = p?p.split('/'):[];
		tk[tk.length] = k;
		var tp = tk.join('/');
		if(typeof(a[k])=='object'){
			s = s.tr(a[k],tp);
		}else{
			s = s.replace((new RegExp('%%'+tp+'%%', 'g')), a[k]);
		};
	});
	return s;
};


var ls = ls || {};

/**
 * Управление всплывающими сообщениями
 */
ls.msg = (function ($) {
	/**
	* Опции
	*/
	this.options = {
		class_notice: 'n-notice',
		class_error: 'n-error'
	};

	/**
	* Отображение информационного сообщения
	*/
	this.notice = function(title,msg){
		$.notifier.broadcast(title, msg, this.options.class_notice);
	};

	/**
	* Отображение сообщения об ошибке
	*/
	this.error = function(title,msg){
		$.notifier.broadcast(title, msg, this.options.class_error);
	};

	return this;
}).call(ls.msg || {},jQuery);


/**
* Доступ к языковым текстовкам (предварительно должны быть прогружены в шаблон)
*/
ls.lang = (function ($) {
	/**
	* Набор текстовок
	*/
	this.msgs = {};

	/**
	* Загрузка текстовок
	*/
	this.load = function(msgs){
		$.extend(true,this.msgs,msgs);
	};

	/**
	* Отображение сообщения об ошибке
	*/
	this.get = function(name,replace){
		if (this.msgs[name]) {
			var value=this.msgs[name];
			if (replace) {
				value = value.tr(replace);
			}
			return value;
		}
		return '';
	};

	return this;
}).call(ls.lang || {},jQuery);

/**
 * Методы таймера например, запуск функии через интервал
 */
ls.timer = (function ($) {

	this.aTimers={};

	/**
	 * Запуск метода через определенный период, поддерживает пролонгацию
	 */
	this.run = function(fMethod,sUniqKey,aParams,iTime){
		iTime=iTime || 1500;
		aParams=aParams || [];
		sUniqKey=sUniqKey || Math.random();

		if (this.aTimers[sUniqKey]) {
			clearTimeout(this.aTimers[sUniqKey]);
			this.aTimers[sUniqKey]=null;
		}
		var timeout = setTimeout(function(){
			clearTimeout(this.aTimers[sUniqKey]);
			this.aTimers[sUniqKey]=null;
			fMethod.apply(this,aParams);
		}.bind(this),iTime);
		this.aTimers[sUniqKey]=timeout;
	};

	return this;
}).call(ls.timer || {},jQuery);

/**
 * Функционал хранения js данных
 */
ls.registry = (function ($) {

	this.aData={};

	/**
	 * Сохранение
	 */
	this.set = function(sName,data){
		this.aData[sName]=data;
	};

	/**
	 * Получение
	 */
	this.get = function(sName){
		return this.aData[sName];
	};

	return this;
}).call(ls.registry || {},jQuery);

/**
* Вспомогательные функции
*/
ls.tools = (function ($) {

	/**
	* Переводит первый символ в верхний регистр
	*/
	this.ucfirst = function(str) {
		var f = str.charAt(0).toUpperCase();
		return f + str.substr(1, str.length-1);
	};

	/**
	* Выделяет все chekbox с определенным css классом
	*/
	this.checkAll = function(cssclass, checkbox, invert) {
		$('.'+cssclass).each(function(index, item){
			if (invert) {
				$(item).attr('checked', !$(item).attr("checked"));
			} else {
				$(item).attr('checked', $(checkbox).attr("checked"));
			}
		});
	};

	/**
	* Предпросмотр
	*/
	this.textPreview = function(textId, save, divPreview) {
		var text = $('#'+textId).val();
		var ajaxUrl = aRouter['ajax']+'preview/text/';
		var ajaxOptions = {text: text, save: save};
		ls.hook.marker('textPreviewAjaxBefore');
		ls.ajax(ajaxUrl, ajaxOptions, function(result){
			if (!result) {
				ls.msg.error('Error','Please try again later');
			}
			if (result.bStateError) {
				ls.msg.error(result.sMsgTitle||'Error',result.sMsg||'Please try again later');
			} else {
				if (!divPreview) {
					divPreview = 'text_preview';
				}
				var elementPreview = $('#'+divPreview);
				ls.hook.marker('textPreviewDisplayBefore');
				if (elementPreview.length) {
					elementPreview.html(result.sText);
					ls.hook.marker('textPreviewDisplayAfter');
				}
			}
		});
	};

	/**
	* Возвращает выделенный текст на странице
	*/
	this.getSelectedText = function(){
		var text = '';
		if(window.getSelection){
			text = window.getSelection().toString();
		} else if(window.document.selection){
			var sel = window.document.selection.createRange();
			text = sel.text || sel;
			if(text.toString) {
				text = text.toString();
			} else {
				text = '';
			}
		}
		return text;
	};


	return this;
}).call(ls.tools || {},jQuery);


/**
* Дополнительные функции
*/
ls = (function ($) {

	/**
	* Глобальные опции
	*/
	this.options = this.options || {};

	/**
	* Выполнение AJAX запроса, автоматически передает security key
	*/
	this.ajax = function(url,params,callback,more){
		more=more || {};
		params=params || {};
		params.security_ls_key=LIVESTREET_SECURITY_KEY;

		$.each(params,function(k,v){
			if (typeof(v) == "boolean") {
				params[k]=v ? 1 : 0;
			}
		});

		if (url.indexOf('http://')!=0 && url.indexOf('https://')!=0 && url.indexOf('/')!=0) {
			url=aRouter['ajax']+url+'/';
		}

		var ajaxOptions = {
			type: more.type || "POST",
			url: url,
			data: params,
			dataType: more.dataType || 'json',
			success: callback || function(){
				ls.debug("ajax success: ");
				ls.debug.apply(this,arguments);
			}.bind(this),
			error: more.error || function(msg){
				ls.debug("ajax error: ");
				ls.debug.apply(this,arguments);
			}.bind(this),
			complete: more.complete || function(msg){
				ls.debug("ajax complete: ");
				ls.debug.apply(this,arguments);
			}.bind(this)
		};
		
		ls.hook.run('ls_ajax_before', [ajaxOptions], this);

		return $.ajax(ajaxOptions);
	};

	/**
	* Выполнение AJAX отправки формы, включая загрузку файлов
	*/
	this.ajaxSubmit = function(url,form,callback,more) {
		more=more || {};
		if (typeof(form)=='string') {
			form=$('#'+form);
		}
		if (url.indexOf('http://')!=0 && url.indexOf('https://')!=0 && url.indexOf('/')!=0) {
			url=aRouter['ajax']+url+'/';
		}

		var options={
			type: 'POST',
			url: url,
			dataType: more.dataType || 'json',
			data: {security_ls_key: LIVESTREET_SECURITY_KEY},
			success: callback || function(){
				ls.debug("ajax success: ");
				ls.debug.apply(this,arguments);
			}.bind(this),
			error: more.error || function(){
				ls.debug("ajax error: ");
				ls.debug.apply(this,arguments);
			}.bind(this)

		};

		ls.hook.run('ls_ajaxsubmit_before', [options], this);
		
		form.ajaxSubmit(options);
	};

	/**
	* Загрузка изображения
	*/
	this.ajaxUploadImg = function(form, sToLoad) {
		ls.hook.marker('ajaxUploadImgBefore');
		var upl_window = $('#window_upload_img');
		var btns = $('.main-upl-btn', upl_window);
		btns.attr('disabled', 'disabled').addClass('disabled').text('Загрузка...');
		ls.ajaxSubmit('upload/image/',form,function(data){
			if (data.bStateError) {
				ls.msg.error(data.sMsgTitle,data.sMsg);
			} else {
				$.markItUp({replaceWith: data.sText} );
				$('#window_upload_img').find('input[type="text"], input[type="file"]').val('');
				$('#window_upload_img').jqmHide();
				ls.hook.marker('ajaxUploadImgAfter');
			}
		});
		btns.removeAttr('disabled').removeClass('disabled').text('Загрузить');
	};

	/**
	* Дебаг сообщений
	*/
	this.debug = function() {
		if (this.options.debug) {
			this.log.apply(this,arguments);
		}
	};

	/**
	* Лог сообщений
	*/
	this.log = function() {
		if (!$.browser.msie && window.console && window.console.log) {
			Function.prototype.bind.call(console.log, console).apply(console, arguments);
		} else {
			//alert(msg);
		}
	};

	return this;
}).call(ls || {},jQuery);



/**
* Автокомплитер
*/
ls.autocomplete = (function ($) {
	/**
	* Добавляет автокомплитер к полю ввода
	*/
	this.add = function(obj, sPath, multiple) {
		if (multiple) {
			obj.bind("keydown", function(event) {
				if ( event.keyCode === $.ui.keyCode.TAB && $( this ).data( "autocomplete" ).menu.active ) {
					event.preventDefault();
				}
			})
			.autocomplete({
				source: function(request, response) {
					ls.ajax(sPath,{value: ls.autocomplete.extractLast(request.term)},function(data){
						response(data.aItems);
					});
				},
				search: function() {
					var term = ls.autocomplete.extractLast(this.value);
					if (term.length < 2) {
						return false;
					}
				},
				focus: function() {
					return false;
				},
				select: function(event, ui) {
					var terms = ls.autocomplete.split(this.value);
					terms.pop();
					terms.push(ui.item.value);
					terms.push("");
					this.value = terms.join(", ");
					return false;
				}
			});
		} else {
			obj.autocomplete({
				source: function(request, response) {
					ls.ajax(sPath,{value: ls.autocomplete.extractLast(request.term)},function(data){
						response(data.aItems);
					});
				}
			});
		}
	};

	this.split = function(val) {
		return val.split( /,\s*/ );
	};

	this.extractLast = function(term) {
		return ls.autocomplete.split(term).pop();
	};

	return this;
}).call(ls.autocomplete || {},jQuery);

(ls.options || {}).debug=1;