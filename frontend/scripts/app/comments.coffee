$ = require "jquery"

{isNull} = require "lodash"
lang = require "core/lang.coffee"
{ajax} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"
{textPreview, registry, prepareJSON} = require "core/tools.coffee"
blocks = require "lib/blocks.coffee"

router = window.aRouter


options =
  type:
    topic:
      url_add:  "#{router.blog}ajaxaddcomment/"
      url_response: "#{router.blog}ajaxresponsecomment/"
    talk:
      url_add: "#{router.talk}ajaxaddcomment/"
      url_response: "#{router.talk}ajaxresponsecomment/"
  classes:
    form_loader: 'loader'
    comment_new: 'comment-new'
    comment_current: 'comment-current'
    comment_deleted: 'comment-deleted'
    comment_self: 'comment-self'
    comment: 'comment'
    comment_goto_parent: 'goto-comment-parent'
    comment_goto_child: 'goto-comment-child'
    comment_hidden: 'comment-hidden'

iCurrentShowFormComment = 0
iCurrentViewComment = null
aCommentNew = []


add = (formObj, targetId, targetType) ->
  formObj = $('#' + formObj)

  $('#form_comment_text').addClass(options.classes.form_loader).attr 'readonly', true
  $('#comment-button-submit').attr 'disabled', 'disabled'

  ajax options.type[targetType].url_add, prepareJSON(formObj), (result) ->
    $('#comment-button-submit').removeAttr 'disabled'
    enableFormComment()
    unless result
      return error 'Error', 'Please try again later'
    if result.bStateError
      return error null, result.sMsg

    $('#form_comment_text').val ''
    load targetId, targetType, result.sCommentId, true


enableFormComment = ->
  $('#form_comment_text').removeClass(options.classes.form_loader).attr 'readonly', false


toggleCommentForm = (idComment, bNoFocus) ->
  reply = $('#reply')
  unless reply.length
    return
  $("#comment_preview_#{iCurrentShowFormComment}").remove()
  if iCurrentShowFormComment == idComment and reply.is(':visible')
    reply.hide()
    return

  reply.insertAfter('#comment_id_' + idComment).show()
  $('#form_comment_text').val ''
  $('#form_comment_reply').val idComment
  iCurrentShowFormComment = idComment
  unless bNoFocus
    $('#form_comment_text').focus()


load = (idTarget, typeTarget, selfIdComment, bNotFlushNew) ->
  idCommentLast = $('#comment_last_id').val()
  # Удаляем подсветку у комментариев
  unless bNotFlushNew
    $('.comment').each (index, item) ->
      $(item).removeClass options.classes.comment_new + ' ' + options.classes.comment_current

  objImg = $('#update-comments')
  objImg.addClass 'active'
  params =
    idCommentLast: idCommentLast
    idTarget: idTarget
    typeTarget: typeTarget

  if selfIdComment
    params.selfIdComment = selfIdComment

  ajax options.type[typeTarget].url_response, params, (result) ->
    objImg.removeClass 'active'
    unless result
      error 'Error', 'Please try again later'
    if result.bStateError
      error null, result.sMsg
    else
      aCmt = result.aComments
      if aCmt.length > 0 and result.iMaxIdComment
        $('#comment_last_id').val result.iMaxIdComment
        $('#count-comments').text parseInt($('#count-comments').text()) + aCmt.length
        curItemBlock = blocks.getCurrentItem('stream')
        if curItemBlock.dataset.type == 'comment'
          blocks.load curItemBlock, 'stream'
      iCountOld = 0
      if bNotFlushNew
        iCountOld = aCommentNew.length
      else
        aCommentNew = []
      if selfIdComment
        toggleCommentForm iCurrentShowFormComment, true
        setCountNewComment aCmt.length - 1 + iCountOld
      else
        setCountNewComment aCmt.length + iCountOld
      $.each aCmt, (index, item) ->
        if !(selfIdComment and selfIdComment == item.id)
          aCommentNew.push item.id
        inject item.idParent, item.id, item.html
        
      if selfIdComment and $('#comment_id_' + selfIdComment).length
        scrollToComment selfIdComment
      checkFolding()


inject = (idCommentParent, idComment, sHtml) ->
  newComment = $('<div>',
    'class': 'comment-wrapper'
    id: 'comment_wrapper_id_' + idComment).html(sHtml)
  if idCommentParent
    # Уровень вложенности родителя
    iCurrentTree = $('#comment_wrapper_id_' + idCommentParent).parentsUntil('#comments').length
    if iCurrentTree == registry.get('comment_max_tree')
      # Определяем id предыдушего родителя
      prevCommentParent = $('#comment_wrapper_id_' + idCommentParent).parent()
      idCommentParent = parseInt(prevCommentParent.attr('id').replace('comment_wrapper_id_', ''))
    $('#comment_wrapper_id_' + idCommentParent).append newComment
  else
    $('#comments').append newComment

  if $('section', newComment).hasClass('comment-bad')
    hide parseInt(idComment), true


toggle = (obj, commentId) ->
  url = "#{router.ajax}comment/delete/"
  params = idComment: commentId
  
  ajax url, params, (result) ->
    unless result
      error 'Error', 'Please try again later'
    if result.bStateError
      error null, result.sMsg
    else
      notice null, result.sMsg
      $('#comment_id_' + commentId).removeClass options.classes.comment_self + ' ' + options.classes.comment_new + ' ' + options.classes.comment_deleted + ' ' + options.classes.comment_current
      if result.bState
        $('#comment_id_' + commentId).addClass options.classes.comment_deleted
      $(obj).text result.sTextToggle

  
preview = (divPreview) ->
  if $('#form_comment_text').val() == ''
    return
  $("#comment_preview_#{iCurrentShowFormComment}").remove()
  $('#reply').before """<div id="comment_preview_#{iCurrentShowFormComment}" class="comment-preview text"></div>"""
  textPreview 'form_comment_text', false, "comment_preview_#{iCurrentShowFormComment}"


setCountNewComment = (count) ->
  if count > 0
    $('#new_comments_counter').show().text count
  else
    $('#new_comments_counter').text(0).hide()


calcNewComments = ->
  aCommentsNew = $('.' + options.classes.comment + '.' + options.classes.comment_new)
  setCountNewComment aCommentsNew.length
  $.each aCommentsNew, (k, v) ->
    aCommentNew.push parseInt($(v).attr('id').replace('comment_id_', ''))
   

goToNextComment = ->
  if aCommentNew[0]
    if $('#comment_id_' + aCommentNew[0]).length
      scrollToComment aCommentNew[0]
    aCommentNew.shift()
  setCountNewComment aCommentNew.length


scrollToComment = (idComment) ->
  $.scrollTo '#comment_id_' + idComment, 300, offset: -250
  if iCurrentViewComment
    $('#comment_id_' + iCurrentViewComment).removeClass options.classes.comment_current
  $('#comment_id_' + idComment).addClass options.classes.comment_current
  iCurrentViewComment = idComment

# Прокрутка к родительскому комментарию

goToParentComment = (id, pid) ->
  thisObj = this
  $('.' + options.classes.comment_goto_child).hide().find('a').unbind()
  $('#comment_id_' + pid).find('.' + options.classes.comment_goto_child).show().find('a').bind 'click', ->
    $(this).parent('.' + options.classes.comment_goto_child).hide()
    thisObj.scrollToComment id
    false
  scrollToComment pid
  false

# Сворачивание комментариев

checkFolding = ->
  $('.folding').each (index, element) ->
    if $(element).parent('.comment').next('.comment-wrapper').length == 0
      $(element).hide()
    else
      $(element).show()
  false

expandComment = (folding) ->
  $(folding).removeClass('folded').parent().nextAll('.comment-wrapper').show()

collapseComment = (folding) ->
  $(folding).addClass('folded').parent().nextAll('.comment-wrapper').hide()


expandCommentAll = ->
  $.each $('.folding'), (k, v) ->
    expandComment v


collapseCommentAll = ->
  $.each $('.folding'), (k, v) ->
    collapseComment v


initEvent = ->
  $('#form_comment_text').bind 'keyup', (e) ->
    key = e.keyCode or e.which
    if e.ctrlKey and key == 13
      $('#comment-button-submit').click()
      return false

  $('.folding').click (e) ->
    if $(e.target).hasClass('folded')
      expandComment e.target
    else
      collapseComment e.target


hiddenCommentsStorageKey = "hidden-comments-#{window.location.pathname}"
storedHiddenComments = {}
hiddenContent = {}
btnUnhide = '<a href="#" onclick="ls.comments.unhide({{id}})">Раскрыть комментарий</a>'

flushHiddenCommentsStorage = ->
  arr = []
  for id of storedHiddenComments
    if Object::hasOwnProperty.call(storedHiddenComments, id)
      arr.push id
  if arr.length
    sessionStorage.setItem hiddenCommentsStorageKey, arr.join(',')
  else
    sessionStorage.removeItem hiddenCommentsStorageKey


hide = (commentId, bNotRemember, bNotFlushStorage) ->
  unless isNull hiddenContent[commentId]
    return error 'Комментарий уже скрыт'

  elComment = $("#comment_id_#{commentId}")
  elText = $('.comment-content .text', elComment)
  hiddenContent[commentId] = elText.html()
  elComment.addClass options.classes.comment_hidden
  elText.html btnUnhide.replace('{{id}}', commentId)
  unless bNotRemember
    storedHiddenComments[commentId] = true
    unless bNotFlushStorage
      flushHiddenCommentsStorage()


unhide = (commentId, bNotFlushStorage) ->
  unless isNull hiddenContent[commentId]
    return error 'Комментарий и так не скрыт'

  elComment = $("#comment_id_#{commentId}")
  $('.comment-content .text', elComment).html hiddenContent[commentId]
  delete @hiddenContent[commentId]
  elComment.removeClass options.classes.comment_hidden
  delete storedHiddenComments[commentId]
  unless bNotFlushStorage
    flushHiddenCommentsStorage()

hide_bad = ->
  # Скроем запомненные скрытые комменты
  if sessionStorage
    storedHiddenComments = sessionStorage.getItem(hiddenCommentsStorageKey)
    if storedHiddenComments
      try
        storedHiddenComments.split(',').forEach (k) ->
          # запоминаем, но пока не сохраняем в storage, чтобы зря не дёргать
          hide parseInt(k), false, true
      catch err
        sessionStorage.removeItem hiddenCommentsStorageKey
        storedHiddenComments = {}
  # сохраняем в storage скрытые комменты
  flushHiddenCommentsStorage()
  $('.comment-bad').each ->
    id = parseInt(@getAttribute('id').replace(/^comment_id_/, ''))
    # не запоминаем в sessionStorage
    hide id, true


init = ->
  initEvent()
  calcNewComments()
  checkFolding()
  toggleCommentForm iCurrentShowFormComment
  hide_bad()

module.exports = {
  init
  hide
  unhide
  goToParentComment
  toggleCommentForm
  toggle
  add
  preview
  load
  goToNextComment
}
