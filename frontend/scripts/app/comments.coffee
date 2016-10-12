$ = require "jquery"
{scrollTo} = require "jquery"
{Set, OrderedSet} = require "immutable"
{keys, map, filter, first, forEach} = require "lodash"
{gettext, ngettext} = require "core/lang.coffee"
{ajax} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"
{textPreview, registry, prepareJSON} = require "core/tools.coffee"
blocks = require "lib/blocks.coffee"
routes = require "lib/routes.coffee"
{commentFor} = require "lib/markitup.coffee"


types =
  topic:
    url_add: routes.topic.comment
    url_response: routes.topic.respond
  talk:
    url_add: routes.talk.comment
    url_response: routes.talk.respond

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
originalTitle = document.title

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
    else
      commentForm.value = ""
      load targetId, targetType, false

  _complete = ({responseJSON:{bStateError}}) ->
    toggleCommentFormState true
    unless bStateError
      toggleCommentForm iCurrentShowFormComment, true

  ajax types[targetType].url_add, prepareJSON(document.getElementById(formId)), _success, _complete


toggleCommentForm = (idComment, bNoFocus) ->
  reply = document.getElementById 'reply'
  unless reply then return

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


toggleEditForm = (idComment, bOpen, bAllowLock=false) ->
  contentWrapper = document.getElementById "comment_content_id_#{idComment}"
  if bOpen
    preview = document.createElement "div"
    preview.className = "text preview"
    preview.id = "comment_preview_edit_#{idComment}"
    currentText = contentWrapper.querySelector(".text.current")
    editForm = document.createElement "div"
    editForm.id = "comment_edit_#{idComment}"
    editForm.className = "edit-form"
    edit = document.createElement "textarea"
    edit.className = "markitup-editor"
    edit.id = "comment_edit_input_#{idComment}"
    edit.style.height = (currentText.getBoundingClientRect().height * 1.2 + 40) + "px"
    edit.value = currentText.innerHTML.replace(/<br[\s]*\/?>\r?\n/gmi, "\n")
    editForm.appendChild preview
    editForm.appendChild edit
    if bAllowLock and document.querySelector("#comment_id_#{idComment} .modify-notice>*")?.dataset.locked != "1"
      lockCB = document.createElement "input"
      lockCB.type = "checkbox"
      lockLabel = document.createElement "label"
      lockLabel.appendChild lockCB
      lockLabel.appendChild document.createTextNode " "+gettext("comment_lock_edit")
      editForm.appendChild lockLabel
    contentWrapper.parentNode?.classList.add "editable"
    contentWrapper.appendChild editForm
    commentFor edit
    edit.focus()
  else
    closeEditForm idComment, contentWrapper
  false

closeEditForm = (idComment, contentWrapper) ->
  $("#comment_edit_#{idComment}").remove()
  contentWrapper.parentNode?.classList.remove "editable"

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
      Set(document.getElementsByClassName(classes.new)).forEach (comment) ->
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
    allParents = [element]
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

  if (newComment.getElementsByClassName(classes.self)).length
    scrollToComment id


toggle = (obj, commentId) ->
  url = routes.comment.delete
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


saveEdit = (idComment) ->
  url = routes.comment.edit
  editForm = document.getElementById "comment_edit_#{idComment}"
  params =
    idComment: idComment
    newText: editForm?.querySelector("textarea")?.value
    setLock: if editForm?.querySelector('label>input[type="checkbox"]')?.checked then "1" else "0"

  _success = (result) ->
    unless result
      return error gettext("server_error"), gettext("try_later")
    if result.newText
      document.querySelector("#comment_content_id_#{idComment} .text.current").innerHTML = result.newText
    if result.notice
      document.querySelector("#comment_id_#{idComment} .modify-notice").innerHTML = result.notice
    if result.bStateError
      return error result.sMsgTitle, result.sMsg
    else
      toggleEditForm idComment, false
      return notice result.sMsgTitle, result.sMsg

  ajax url, params, _success
  false

previewEdit = (idComment) ->
  preview_id = "comment_preview_edit_#{idComment}"
  document.getElementById(preview_id).innerHTML = ""
  textPreview "comment_edit_input_#{idComment}", false, preview_id, true
  return false

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
  newCounter.textContent = count
  if count
    document.title = count + ' | ' + originalTitle
    newCounter.classList.remove "h-hidden"
  else
    document.title = originalTitle
    newCounter.classList.add "h-hidden"


setCountAllComment = (count) ->
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
  comment = document.getElementById "comment_id_#{commentId}"
  unless comment
    return

  scrollTo comment, 300, offset: -250

  if currentViewedCommentId
    previousViewedComment = document.getElementById "comment_id_#{currentViewedCommentId}"
    if previousViewedComment
      previousViewedComment.classList.remove classes.current

  if newCounter
    newComments = newComments.delete commentId
    setCountNewComment newComments.size
  
  comment.classList.remove classes.new
  comment.classList.add classes.current

  currentViewedCommentId = parseInt comment.dataset.id


goToParentComment = (id, pid) ->
  scrollToComment pid
  goToChild = $('#comment_id_'+pid+' .goto-comment-child>a')
  $(goToChild).parent().show()
  $(goToChild).attr('href','#'+id)
  $(goToChild).attr('onclick', '{ls.comments.scrollToComment('+id+');$(this).parent().hide();$(this).attr("onclick","")}')

initEvent = ->
  if commentForm
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

  if newCounter
    $(document).keydown (e) ->
      if !$("textarea:focus,input:focus").length
        key = e.keyCode or e.which
        if [32,45].indexOf(key) != -1
          e.preventDefault()
          $(newCounter).click()
        else if [13,46].indexOf(key) != -1
          e.preventDefault()
          $("#update-comments").click()

init = ->
  newCounter = document.getElementById "new_comments_counter"
  allCounter = document.getElementById "count-comments"
  commentForm = document.getElementById "form_comment_text"
  initEvent()
  setCountAllComment parseAllCommentTree()
  setCountNewComment parseNewCommentTree()
  toggleCommentForm iCurrentShowFormComment
  if commentForm
    $(document)
      .on('mouseup', (e) -> 
        #проверяем нажата ли левая кнопка
        if e.which != 1 then return
        selection = window.getSelection()
        text = selection
          .toString()
          .replace(/&/g,"&amp;")
          .replace(/</g,"&lt;")
          .replace(/>/g,"&gt;")
          .replace(/"/g,"&quot;")
          .replace(/'/g,"&#039;")
        if !text then return
        #ищем родительский комментарий
        parentComment = $(selection.anchorNode.parentElement).parentsUntil(".comment").filter(".comment-content")
        parentID = 0
        if parentComment.length 
          parentID = parentComment.attr("id").replace("comment_content_id_","")
        x = e.clientX + $(window).scrollLeft()
        y = e.clientY + $(window).scrollTop()
        #создаём элемент если нужно
        if !$("#quote").length 
          $("body").append('<div data-parent-id="" data-quote="" id="quote"><i>&nbsp;</i>цитировать<s>&nbsp;</s></div>')
        quote = $("#quote")
        $(quote).attr("data-quote",text)
        $(quote).attr("data-parent-id",parentID)
        $(quote).css('left',x)
        $(quote).css('top',y)
        $(quote).show()
      )
      .on('mousedown', ->
        $("#quote").hide()
      )
      .on('mouseup', '#quote', (e) ->
        e.stopPropagation()
        if $("#reply").hasClass("h-hidden")
          iCurrentShowFormComment = $(this).attr("data-parent-id")
          toggleCommentForm(iCurrentShowFormComment,false)
        #ищем каретку в форме редактирования
        caret = commentForm.selectionStart
        if isNaN caret
          commentForm.value += '<blockquote>'+$(this).attr("data-quote")+'</blockquote>'
        else
          commentForm.value = 
            commentForm.value.substring(0,caret) +
            '<blockquote>'+$(this).attr("data-quote")+'</blockquote>' +
            commentForm.value.substring(caret)
        $(this).hide()
        #если форма редактирования не видна, мотаем
        commentFormPosition = $(commentForm).offset().top
        windowPosition = $(window).scrollTop()
        if (commentFormPosition + commentForm.getClientRects()[0].height < windowPosition) || (commentFormPosition > (windowPosition + $(window).height()))
          scrollToComment(iCurrentShowFormComment)
      )
      .on('mousedown','#quote', (e) ->
        e.stopPropagation()
      )



module.exports = {
  init
  goToParentComment
  scrollToComment
  toggleCommentForm
  toggle
  toggleEditForm
  previewEdit
  saveEdit
  add
  preview
  load
  goToNextComment
}
