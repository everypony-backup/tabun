$ = require "jquery"
{scrollTo} = require "jquery"
{Set, OrderedSet} = require "immutable"
{keys, map, filter, first, forEach} = require "lodash"
{gettext, ngettext} = require "core/lang.coffee"
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
  wrapper: 'comment-wrapper'
  self: 'comment-self'
  folded: 'folded'
  comment: 'comment'
  comment_goto_parent: 'goto-comment-parent'
  comment_goto_child: 'goto-comment-child'
  comment_hidden: 'comment-hidden'

hideClasses = [classes.self, classes.new, classes.deleted, classes.current]

iCurrentShowFormComment = 0
currentViewedCommentId = null

newComments = new Set()
allComments = new OrderedSet()
newCounter = null
allCounter = null
commentForm = null

toggleCommentFormState = (state) ->
  submitButton = document.getElementById "comment-button-submit"

  if state
    commentForm.classList.remove classes.form_loader
    commentForm.readOnly = false
    submitButton.disabled = false
  else
    commentForm.classList.add classes.form_loader
    commentForm.readOnly = true
    submitButton.disabled = true
  null

add = (formId, targetId, targetType) ->
  toggleCommentFormState false

  _success = (result) ->
    unless result
      return error gettext("server_error"), gettext("try_later")
    if result.bStateError
      return error gettext("common_error"), result.sMsg

    commentForm.value = ""
    load targetId, targetType, false

  _complete = (result) ->
    toggleCommentFormState true
    toggleCommentForm iCurrentShowFormComment, true

  ajax types[targetType].url_add, prepareJSON(document.getElementById(formId)), _success, _complete


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

  commentForm.value = ""
  document.getElementById("form_comment_reply").value = idComment
  iCurrentShowFormComment = idComment
  unless bNoFocus
    commentForm.focus()


load = (idTarget, typeTarget, bFlushNew=true) ->
  idCommentLast = parseInt(newCounter.dataset.idCommentLast) || 0
  objImg = document.getElementById 'update-comments'
  objImg.classList.add 'active'
  params =
    idCommentLast: idCommentLast
    idTarget: idTarget
    typeTarget: typeTarget

  _success = (result) ->
    if result.bStateError
      return error gettext("common_error"), result.sMsg

    if bFlushNew
      forEach document.getElementsByClassName(classes.new), (comment) ->
        comment.classList.remove classes.new
        comment.classList.remove classes.current

    forEach result.comments, (comment, id) ->
      unless allComments.contains parseInt id
        inject comment

    setCountNewComment parseNewCommentTree()
    setCountAllComment parseAllCommentTree()

    if keys(result.comments) > 0
      curItemBlock = blocks.getCurrentItem 'stream'
      if curItemBlock?.dataset.type == 'comment'
        blocks.load curItemBlock, 'stream'
      newCounter.dataset.idCommentLast = result.iMaxIdComment

  _complete = -> objImg.classList.remove 'active'

  ajax types[typeTarget].url_response, params, _success, _complete


inject = ({pid, id, html}) ->
  newComment = document.createElement 'div'
  newComment.classList.add classes.wrapper
  newComment.id = "comment_wrapper_id_#{id}"
  newComment.innerHTML = html

  if pid
    element = document.getElementById "comment_wrapper_id_#{pid}"
    allParents = []
    allParents.push(element)
    while element.parentNode
      if element.classList and classes.wrapper in element.classList
        allParents.unshift(element.parentNode)
      element = element.parentNode

    if allParents.length == registry.get('comment_max_tree')
      target = allParents[allParents.length - 2]
    else
      target = allParents[allParents.length - 1]
  else
    target = document.getElementById "comments"

  target.appendChild newComment
  if newComment.getElementsByClassName classes.self
    scrollToComment id


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
  unless commentForm.value
    return

  old_preview = document.getElementById "comment_preview_#{iCurrentShowFormComment}"
  old_preview?.parentNode?.removeChild old_preview

  new_preview = document.createElement "div"
  new_preview.className = "comment-preview text"
  new_preview.id = "comment_preview_#{iCurrentShowFormComment}"

  reply = document.getElementById("reply")
  reply.parentNode.insertBefore new_preview, reply

  textPreview 'form_comment_text', false, "comment_preview_#{iCurrentShowFormComment}"


setCountNewComment = (count) ->
  console.debug "New comments count: #{newCounter.textContent} -> #{count}"
  newCounter.textContent = count
  if count
    newCounter.classList.remove "h-hidden"
  else
    newCounter.classList.add "h-hidden"


setCountAllComment = (count) ->
  console.debug "All comments count: #{allCounter.textContent} -> #{count}"
  document.getElementById("name-count-comments").textContent = ngettext "comment", "comments", count
  allCounter.textContent = count

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
  if commentId then scrollToComment commentId


scrollToComment = (commentId) ->
  previousViewedComment = document.getElementById "comment_id_#{currentViewedCommentId}"
  if previousViewedComment
    previousViewedComment.classList.remove classes.current

  comment = document.getElementById "comment_id_#{commentId}"
  unless comment
    console.warn "There're no comment #{commentId}"
    return

  scrollTo comment, 300, offset: -250

  newComments = newComments.delete commentId
  setCountNewComment newComments.size

  comment.classList.remove classes.new
  comment.classList.add classes.current

  currentViewedCommentId = parseInt comment.dataset.id


goToParentComment = (id, pid) ->
  $('.' + classes.comment_goto_child).hide().find('a').unbind()
  $('#comment_id_' + pid).find('.' + classes.comment_goto_child).show().find('a').bind 'click', ->
    $(this).parent('.' + classes.comment_goto_child).hide()
    scrollToComment id
  scrollToComment pid

initEvent = ->
  $(commentForm).on 'keyup', ({keyCode, which, ctrlKey}) ->
    key = keyCode or which
    if ctrlKey and key == 13
      $('#comment-button-submit').click()

  $(document).on "click", '.folding', ({target}) ->
    wrappers = document
      .getElementById "comment_wrapper_id_#{target.dataset.id}"
      .getElementsByClassName classes.wrapper

    if classes.folded in target.classList
      # Expand
      target.classList.remove classes.folded
      forEach wrappers, (wrapper) -> wrapper.classList.remove 'h-hidden'
    else
      # Collapse
      target.classList.add classes.folded
      forEach wrappers, (wrapper) -> wrapper.classList.add 'h-hidden'


init = ->
  newCounter = document.getElementById "new_comments_counter"
  allCounter = document.getElementById "count-comments"
  commentForm = document.getElementById "form_comment_text"
  initEvent()
  setCountAllComment parseAllCommentTree()
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
