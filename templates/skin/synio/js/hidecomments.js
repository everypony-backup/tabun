(function($) {

    ls = ls || {};
    ls.comments = ls.comments || {};
    ls.comments.options = ls.comments.options || {};
    ls.comments.options.classes = ls.comments.options.classes || {};

    ls.comments.options.classes.comment_hidden = 'comment-hidden';
    var tmp = /[0-9]+\.html\/?$/.exec(window.location.pathname)
      , tmp2 = /talk\/read\/([0-9]+)\/?$/.exec(window.location.pathname)
      , topicId = tmp && tmp.length ? tmp[0] : tmp2 && tmp2.length ? 'talk-'+tmp2[1] : null
      , hiddenCommentsStorageKey = 'hidden-comments-' + topicId
      , storedHiddenComments = {}
      , btnUnhide = '<a href="javascript:void(0)" onclick="ls.comments.unhide({{id}})">Раскрыть комментарий</a>';

    if (topicId == null) {
        return; // мы не в топике, здесь этому плагину делать нечего
    }

    var flushHiddenCommentsStorage = function() {
        var arr = []
        for (var id in storedHiddenComments) {
            if (Object.prototype.hasOwnProperty.call(storedHiddenComments, id)) {
                arr.push(id);
            }
        }
        if (arr.length) {
            sessionStorage.setItem(hiddenCommentsStorageKey, arr.join(','));
        } else {
            sessionStorage.removeItem(hiddenCommentsStorageKey);
        }
    }

    ls.comments.hiddenContent = {};

    ls.comments.hide = function(commentId, bNotRemember, bNotFlushStorage) {
        if (this.hiddenContent[commentId] == null) {
            var elComment = $('#comment_id_' + commentId)
              , elText = $('.comment-content .text', elComment);

            this.hiddenContent[commentId] = elText.html();
            elComment.addClass(this.options.classes.comment_hidden);
            elText.html(btnUnhide.replace('{{id}}', commentId));

            if (!bNotRemember) {
                storedHiddenComments[commentId] = true;
                if (!bNotFlushStorage) {
                    flushHiddenCommentsStorage();
                }
            }
        } else {
            ls.msg.error('Комментарий уже скрыт');
        }
	return false;
    }

    ls.comments.unhide = function(commentId, bNotFlushStorage) {
        if (this.hiddenContent[commentId] != null) {
            var elComment = $('#comment_id_' + commentId);
            $('.comment-content .text', elComment).html(this.hiddenContent[commentId]);
            delete this.hiddenContent[commentId];
            elComment.removeClass(this.options.classes.comment_hidden);

            delete storedHiddenComments[commentId];
            if (!bNotFlushStorage) {
                flushHiddenCommentsStorage();
            }
        } else {
            ls.msg.error('Комментарий и так не скрыт');
        }
	return false;
    }

    // Скроем запомненные скрытые комменты
    $(function() {

        if (sessionStorage) {
            var storedHiddenComments = sessionStorage.getItem(hiddenCommentsStorageKey);
            if (storedHiddenComments) {
                try {
                    storedHiddenComments.split(',').forEach(function(k) {
                        // запоминаем, но пока не сохраняем в storage, чтобы зря не дёргать
                        ls.comments.hide(parseInt(k), false, true);
                    });
                } catch(err) {
                    sessionStorage.removeItem(hiddenCommentsStorageKey);
                    storedHiddenComments = {};
                }
            }
        }

        // сохраняем в storage скрытые комменты
        flushHiddenCommentsStorage();

        $('.comment-bad').each(function() {
            var id = parseInt(this.getAttribute('id').replace(/^comment_id_/, ''));
            // не запоминаем в sessionStorage
            ls.comments.hide(id, true);
        })

        // подгрузка уже заминусованных комментов
        ls.hook.add('ls_comment_inject_after', function(nothing, comment_id, comment_text) {
            // "this" is a jQuery object
            if ($('section', this).hasClass('comment-bad')) {
                ls.comments.hide(parseInt(comment_id), true);
            }
        })

    });

})(jQuery);
