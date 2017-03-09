$ = require "jquery"
{forEach, debounce, uniqueId, isString} = require "lodash"

{ajax, ajaxSubmit} = require "core/ajax.coffee"
lang = require "core/lang.coffee"
{notice, error} = require "core/messages.coffee"
{subscribe, unsubscribe} = require "app/stream.coffee"
routes = require "lib/routes.coffee"

jcropAvatar = null
jcropFoto = null

addFriend = (obj, idUser, sAction) ->
  if sAction not in ['link', 'accept']
    sText = $('#add_friend_text').val()
    forEach $('#add_friend_form').children(), (node) -> node.setAttribute 'disabled', 'disabled'
  else
    sText = ''

  url = if sAction == 'accept' then routes.profile.acceptFriendship else routes.profile.addFriend

  params =
    idUser: idUser
    userText: sText

  ajax url, params, (result) ->
    forEach $('#add_friend_form').children(), (node) -> node.removeAttribute 'disabled'

    unless result
      return error 'Error', 'Please try again later'
    if result.bStateError
      return error null, result.sMsg
    notice null, result.sMsg

    $('#add_friend_form').jqmHide()
    $('#add_friend_item').remove()
    $('#profile_actions').prepend $(result.sToggleText)

removeFriend = (obj, idUser, sAction) ->
  url = routes.profile.removeFriend
  params =
    idUser: idUser
    sAction: sAction

  ajax url, params, (result) ->
    if result.bStateError
      return error null, result.sMsg
    notice null, result.sMsg
    $('#delete_friend_item').remove()
    $('#profile_actions').prepend $(result.sToggleText)
  false

uploadAvatar = (form, input) ->
  if not form and input
    form = $('<form method="post" enctype="multipart/form-data"></form>').css('display': 'none').appendTo('body')
    clone = input.clone(true)
    input.hide()
    clone.insertAfter input
    input.appendTo form

  ajaxSubmit routes.image.uploadAvatar, form, (data) ->
    if data.bStateError
      error data.sMsgTitle, data.sMsg
    else
      showResizeAvatar data.sTmpFile

showResizeAvatar = (sImgFile) ->
  if jcropAvatar
    jcropAvatar.destroy()

  $('#avatar-resize-original-img').attr 'src', "#{sImgFile}?#{uniqueId()}"
  $('#avatar-resize').jqmShow()
  $('#avatar-resize-original-img').Jcrop {aspectRatio: 1, minSize: [32, 32]}, ->
    jcropAvatar = @
    @setSelect [0, 0, 500, 500]

resizeAvatar = ->
  unless jcropAvatar
    return false

  params = size: jcropAvatar.tellSelect()

  ajax routes.image.resizeAvatar, params, (result) ->
    if result.bStateError
      return error null, result.sMsg
    $('#avatar-img').attr 'src', "#{result.sFile}?#{uniqueId()}"
    $('#avatar-resize').jqmHide()
    $('#avatar-remove').show()
    $('#avatar-upload').text result.sTitleUpload
  false

removeAvatar = ->
  ajax routes.image.removeAvatar, {}, (result) ->
    if result.bStateError
      return error null, result.sMsg

    $('#avatar-img').attr 'src', "#{result.sFile}?#{uniqueId()}"
    $('#avatar-remove').hide()
    $('#avatar-upload').text result.sTitleUpload

  false

cancelAvatar = ->
  ajax routes.image.cancelAvatar, {}, (result) ->
    if result.bStateError
      return error null, result.sMsg
    $('#avatar-resize').jqmHide()
  false

uploadFoto = (form, input) ->
  if not form and input
    form = $('<form method="post" enctype="multipart/form-data"></form>').css('display': 'none').appendTo('body')
    clone = input.clone(true)
    input.hide()
    clone.insertAfter input
    input.appendTo form

  ajaxSubmit routes.image.uploadFoto, form, (data) ->
    if data.bStateError
      return error data.sMsgTitle, data.sMsg

    showResizeFoto data.sTmpFile

showResizeFoto = (sImgFile) ->
  if jcropFoto
    jcropFoto.destroy()

  $('#foto-resize-original-img').attr 'src', "#{sImgFile}?#{uniqueId()}"
  $('#foto-resize').jqmShow()
  $('#foto-resize-original-img').Jcrop minSize: [32, 32], ->
    jcropFoto = @
    @setSelect [0, 0, 500, 500]

resizeFoto = ->
  unless jcropFoto
    return false
  params = size: jcropFoto.tellSelect()

  ajax routes.image.resizeFoto, params, (result) ->
    if result.bStateError
      return error null, result.sMsg

    $('#foto-img').attr 'src', "#{result.sFile}?#{uniqueId()}"
    $('#foto-resize').jqmHide()
    $('#foto-remove').show()
    $('#foto-upload').text result.sTitleUpload

  false

removeFoto = ->
  ajax routes.image.removeFoto, {}, (result) ->
    if result.bStateError
      return error null, result.sMsg
    $('#foto-img').attr 'src', "#{result.sFile}?#{uniqueId()}"
    $('#foto-remove').hide()
    $('#foto-upload').text result.sTitleUpload

cancelFoto = ->
  ajax routes.image.cancelFoto, {}, (result) ->
    if result.bStateError
      return error null, result.sMsg

    $('#foto-resize').jqmHide()

  false


formLoader = (form, bHide) ->
  forEach form.find('input[type="text"], input[type="password"]'), (node) ->
    $(node).toggleClass 'loader', bHide

reactivation = (form) ->
  if isString form then form = $ "##{form}"

  ajaxSubmit routes.profile.reactivate, form, (result) ->

    form
    .find '.validate-error-show' 
    .removeClass 'validate-error-show' 
    .addClass 'validate-error-hide'

    if result.bStateError
      form
      .find '.validate-error-reactivation' 
      .removeClass 'validate-error-hide' 
      .addClass 'validate-error-show' 
      .text result.sMsg
    else
      form.find('input').val ''
      if result.sMsg then notice null, result.sMsg


searchUsers = (form) ->
  url = routes.people.search
  if isString form then form = $ "##{form}"

  formLoader form

  ajaxSubmit url, form, (result) ->
    formLoader form, true
    $('#users-list-original').toggleClass('h-hidden', not result.bStateError)
    $('#users-list-search').html(result.sText or '').toggleClass('h-hidden', result.bStateError)

searchUsersThrottled = debounce searchUsers, 500


searchUsersByPrefix = (sPrefix, obj) ->
  obj = $(obj)
  params =
    user_login: sPrefix
    isPrefix: 1

  $('#search-user-login').addClass 'loader'

  ajax routes.people.search, params, (result) ->
    $('#search-user-login').removeClass 'loader'
    $('#user-prefix-filter .active').removeClass 'active'
    obj.parent().addClass 'active'
    $('#users-list-original').toggleClass('h-hidden', not result.bStateError)
    $('#users-list-search').html(result.sText or '').toggleClass('h-hidden', result.bStateError)

  false


followToggle = (obj, iUserId) ->
  if $(obj).hasClass('followed')
    unsubscribe iUserId
    $(obj).toggleClass('followed').text gettext('user_follow')
  else
    subscribe iUserId
    $(obj).toggleClass('followed').text gettext('user_unfollow')
  false

module.exports = {
  reactivation
  searchUsersThrottled
  searchUsersByPrefix
  removeFriend
  addFriend
  followToggle
  uploadFoto
  removeFoto
  resizeFoto
  cancelFoto
  uploadAvatar
  removeAvatar
  resizeAvatar
  cancelAvatar
}