$ = require "jquery"
{Set, OrderedSet} = require "immutable"
{keys, map, filter, forEach, transform} = require "lodash"
{gettext} = require "core/lang.coffee"
{ajax} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"
{textPreview, registry, prepareJSON} = require "core/tools.coffee"
blocks = require "lib/blocks.coffee"

router = window.aRouter


types =
  topic:
    url_add:  "#{router.blog}ajaxaddcomment/"
    url_response: "#{router.blog}ajaxresponsecomment/"
  talk:
    url_add: "#{router.talk}ajaxaddcomment/"
    url_response: "#{router.talk}ajaxresponsecomment/"

classes =
  form_loader: 'loader'
  new: 'comment-new'
  current: 'comment-current'
  deleted: 'comment-deleted'
  self: 'comment-self'
  folded: 'folded'
  comment: 'comment'
  comment_goto_parent: 'goto-comment-parent'
  comment_goto_child: 'goto-comment-child'
  comment_hidden: 'comment-hidden'

hideClasses = [classes.self, classes.new, classes.deleted, classes.current]

iCurrentShowFormComment = 0
iCurrentViewComment = null

newComments = new Set()
allComments = new OrderedSet()

toggleCommentFormState = (state) ->
  commentForm = $ '#form_comment_text'
  submitButton = $ '#comment-button-submit'

  commentForm.toggleClass classes.form_loader, not state
  commentForm.attr 'readonly', not state
  if state
    submitButton.removeAttr 'disabled'
  else
    submitButton.attr 'disabled', 'disabled'
  null

add = (formId, targetId, targetType) ->
  form = $ "##{formId}"

  toggleCommentFormState false

  _success = (result) ->
    unless result
      return error gettext("server_error"), gettext("try_later")
    if result.bStateError
      return error gettext("common_error"), result.sMsg

    $('#form_comment_text').val ''
    load targetId, targetType, result.sCommentId, false

  _complete = -> toggleCommentFormState true

  ajax types[targetType].url_add, prepareJSON(form), _success, null, _complete


toggleCommentForm = (idComment, bNoFocus) ->
  reply = document.getElementById 'reply'
  unless reply then return

  # Throw away old previews
  preview = document.getElementById "comment_preview_#{iCurrentShowFormComment}"
  preview?.parentNode?.removeChild preview

  if iCurrentShowFormComment == idComment and 'h-hidden' not in reply.classList
    reply.classList.add 'h-hidden'
    return

  commentNode = document.getElementById "comment_id_#{idComment}"
  commentNode.parentNode.insertBefore reply, commentNode.nextSibling
  reply.classList.remove 'h-hidden'

  $('#form_comment_text').val ''
  $('#form_comment_reply').val idComment
  iCurrentShowFormComment = idComment
  unless bNoFocus
    $('#form_comment_text').focus()


load = (idTarget, typeTarget, selfIdComment, bFlushNew=true) ->
  newCounter = document.getElementById 'new_comments_counter'
  idCommentLast = parseInt(newCounter.dataset.idCommentLast) || 0

  objImg = document.getElementById 'update-comments'
  objImg.classList.add 'active'
  params =
    idCommentLast: idCommentLast
    idTarget: idTarget
    typeTarget: typeTarget

  if selfIdComment
    params.selfIdComment = selfIdComment

  _success = (result) ->
    unless result
      return error gettext("server_error"), gettext("try_later")
    if result.bStateError
      return error gettext("common_error"), result.sMsg

    curItemBlock = blocks.getCurrentItem 'stream'
    if curItemBlock?.dataset.type == 'comment'
      blocks.load curItemBlock, 'stream'

    ###*
    # TODO: fix this workaround with direct iterating over new aComments structure
    # TODO: it should be aComments = HashMap<Int, Comment>
    ###
    rawComments = transform(
      result.aComments
      (accumulator, value) -> accumulator[value.id] = value
      {}
    )
    forEach rawComments, (comment, id) ->
      unless allComments.contains parseInt id
        inject comment

    if bFlushNew
      newComments.forEach (newCommentId) ->
        comment = document.getElementById "comment_id_#{newCommentId}"
        comment.classList.remove classes.new
        comment.classList.remove classes.current

    setCountNewComment parseNewCommentTree()
    setCountAllComment parseAllCommentTree()
    newCounter.dataset.idCommentLast = result.iMaxIdComment

    if selfIdComment
      toggleCommentForm iCurrentShowFormComment, true

    if selfIdComment and document.getElementById "comment_id_#{selfIdComment}"
      scrollToComment selfIdComment

  _complete = -> objImg.classList.remove 'active'

  ajax types[typeTarget].url_response, params, _success, null, _complete


inject = ({idParent, id, html}) ->
  newComment = document.createElement 'div'
  newComment.classList.add 'comment-wrapper'
  newComment.id = "comment_wrapper_id_#{id}"
  newComment.innerHTML = html

  if idParent
    # Уровень вложенности родителя
    iCurrentTree = $('#comment_wrapper_id_' + idParent).parentsUntil('#comments').length
    if iCurrentTree == registry.get('comment_max_tree')
      # Определяем id предыдушего родителя
      prevCommentParent = $('#comment_wrapper_id_' + idParent).parent()
      idParent = parseInt(prevCommentParent.attr('id').replace('comment_wrapper_id_', ''))
    targetId = "comment_wrapper_id_#{idParent}"
  else
    targetId = 'comments'

  document.getElementById(targetId).appendChild newComment


toggle = (obj, commentId) ->
  url = "#{router.ajax}comment/delete/"
  params = idComment: commentId

  _success = (result) ->
    unless result
      return error gettext("server_error"), gettext("try_later")
    if result.bStateError
      return error gettext("common_error"), result.sMsg

    notice null, result.sMsg
    comment = document.getElementById "comment_id_#{commentId}"
    forEach hideClasses, (className) -> comment.classList.remove className
    if result.bState
      comment.classList.add classes.deleted
    obj.text result.sTextToggle

  ajax url, params, _success


preview = ->
  if $('#form_comment_text').val() == ''
    return
  $("#comment_preview_#{iCurrentShowFormComment}").remove()
  $('#reply').before """<div id="comment_preview_#{iCurrentShowFormComment}" class="comment-preview text"></div>"""
  textPreview 'form_comment_text', false, "comment_preview_#{iCurrentShowFormComment}"


setCountNewComment = (count) ->
  $('#new_comments_counter').text(count).toggleClass('h-hidden', !count)

setCountAllComment = (count) ->
  document.getElementById("count-comments").text = count

parseAllCommentTree = ->
  allComments = Set map(
    document.getElementsByClassName(classes.comment)
    (comment) -> parseInt comment.dataset.id
  )
  allComments.size

parseNewCommentTree = ->
  newComments = OrderedSet map(
    document.getElementsByClassName(classes.new)
    (comment) -> parseInt comment.dataset.id
  )
  newComments.size

goToNextComment = ->
  commentId = newComments.first()
  if commentId
    if document.getElementById "comment_id_#{commentId}"
      scrollToComment commentId
    newComments = newComments.delete commentId
  setCountNewComment newComments.size


scrollToComment = (idComment) ->
  $.scrollTo "#comment_id_#{idComment}", 300, offset: -250
  if iCurrentViewComment
    $("#comment_id_#{iCurrentViewComment}").removeClass classes.current
  $("#comment_id_#{idComment}").addClass classes.current
  iCurrentViewComment = idComment

goToParentComment = (id, pid) ->
  $('.' + classes.comment_goto_child).hide().find('a').unbind()
  $('#comment_id_' + pid).find('.' + classes.comment_goto_child).show().find('a').bind 'click', ->
    $(this).parent('.' + classes.comment_goto_child).hide()
    scrollToComment id
  scrollToComment pid

initEvent = ->
  $('#form_comment_text').on 'keyup', ({keyCode, which, ctrlKey}) ->
    key = keyCode or which
    if ctrlKey and key == 13
      $('#comment-button-submit').click()

  $(document).on "click", '.folding', ({target}) ->
    wrappers = document
      .getElementById "comment_wrapper_id_#{target.dataset.id}"
      .getElementsByClassName "comment-wrapper"

    if classes.folded in target.classList
      # Expand
      target.classList.remove classes.folded
      forEach wrappers, (wrapper) -> wrapper.classList.remove 'h-hidden'
    else
      # Collapse
      target.classList.add classes.folded
      forEach wrappers, (wrapper) -> wrapper.classList.add 'h-hidden'


init = ->
  initEvent()
  parseAllCommentTree()
  setCountNewComment parseNewCommentTree()
  toggleCommentForm iCurrentShowFormComment

module.exports = {
  init
  goToParentComment
  toggleCommentForm
  toggle
  add
  preview
  load
  goToNextComment
}
