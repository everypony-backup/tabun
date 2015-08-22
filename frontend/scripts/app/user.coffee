$ = require "jquery"
{forEach, first, throttle, uniqueId, isString} = require "lodash"

{ajax, ajaxSubmit} = require "core/ajax.coffee"
lang = require "core/lang.coffee"
{notice, error} = require "core/messages.coffee"
{subscribe, unsubscribe} = require "app/stream.coffee"

router = window.aRouter

jcropAvatar = null
jcropFoto = null

addFriend = (obj, idUser, sAction) ->
  if sAction not in ['link', 'accept']
    sText = $('#add_friend_text').val()
    forEach $('#add_friend_form').children(), (node) -> node.setAttribute 'disabled', 'disabled'
  else
    sText = ''

  url = if sAction == 'accept' then "#{router.profile}ajaxfriendaccept/" else "#{router.profile}ajaxfriendadd/"

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
  url = "#{router.profile}ajaxfrienddelete/"
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

  ajaxSubmit "#{router.settings}profile/upload-avatar/", form, (data) ->
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

  url = "#{router.settings}profile/resize-avatar/"
  params = size: jcropAvatar.tellSelect()

  ajax url, params, (result) ->
    if result.bStateError
      return error null, result.sMsg
    $('#avatar-img').attr 'src', "#{result.sFile}?#{uniqueId()}"
    $('#avatar-resize').jqmHide()
    $('#avatar-remove').show()
    $('#avatar-upload').text result.sTitleUpload
  false

removeAvatar = ->
  url = "#{router.settings}profile/remove-avatar/"
  params = {}

  ajax url, params, (result) ->
    if result.bStateError
      return error null, result.sMsg

    $('#avatar-img').attr 'src', "#{result.sFile}?#{uniqueId()}"
    $('#avatar-remove').hide()
    $('#avatar-upload').text result.sTitleUpload

  false

cancelAvatar = ->
  url = "#{router.settings}profile/cancel-avatar/"
  params = {}

  ajax url, params, (result) ->
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

  ajaxSubmit "#{router.settings}profile/upload-foto/", form, (data) ->
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
  url = "#{router.settings}profile/resize-foto/"
  params = size: jcropFoto.tellSelect()

  ajax url, params, (result) ->
    if result.bStateError
      return error null, result.sMsg

    $('#foto-img').attr 'src', "#{result.sFile}?#{uniqueId()}"
    $('#foto-resize').jqmHide()
    $('#foto-remove').show()
    $('#foto-upload').text result.sTitleUpload

  false

removeFoto = ->
  url = "#{router.settings}profile/remove-foto/"
  params = {}

  ajax url, params, (result) ->
    if result.bStateError
      return error null, result.sMsg
    $('#foto-img').attr 'src', "#{result.sFile}?#{uniqueId()}"
    $('#foto-remove').hide()
    $('#foto-upload').text result.sTitleUpload

cancelFoto = ->
  url = "#{router.settings}profile/cancel-foto/"
  params = {}

  ajax url, params, (result) ->
    if result.bStateError
      return error null, result.sMsg

    $('#foto-resize').jqmHide()

  false

validateRegistrationFields = (aFields, sForm) ->
  url = "#{router.registration}ajax-validate-fields/"
  params = fields: aFields
  if isString sForm
    sForm = $ "##{sForm}"

  ajax url, params, (result) ->
    unless sForm
      sForm = $('body')
    # поиск полей по всей странице
    forEach aFields, (aField) ->
      bIsError = result.aErrors and result.aErrors[aField.field][0]
      errField = sForm.find(".validate-error-field-#{aField.field}")

      sForm.find(".validate-ok-field-#{aField.field}").toggle(not bIsError)
      sForm.find(".form-item-help-#{aField.field}").toggleClass 'active', not bIsError
      errField.toggleClass('validate-error-show', bIsError)
      errField.toggleClass('validate-error-hide', not bIsError)

      if bIsError
        sForm.text result.aErrors[aField.field][0]

validateRegistrationField = (sField, sValue, sForm, aParams = {}) ->
  aFields = [{
    field: sField
    value: sValue
    params: aParams
  }]
  validateRegistrationFields aFields, sForm

registration = (form) ->
  url = "#{router.registration}ajax-registration/"
  if isString form then form = $ "##{form}"

  formLoader form

  ajaxSubmit url, form, (result) ->
    formLoader form, true

    if result.bStateError
      return error null, result.sMsg

    form
    .find '.validate-error-show'
    .removeClass 'validate-error-show'
    .addClass 'validate-error-hide'

    if result.aErrors
      forEach result.aErrors, (sField) ->
        error = first aErrors
        if error
          form
          .find ".validate-error-field-#{sField}"
          .removeClass 'validate-error-hide'
          .addClass 'validate-error-show'
          .text error

    else
      if result.sMsg then notice null, result.sMsg
      if result.sUrlRedirect then window.location = result.sUrlRedirect

login = (form) ->
  url = "#{router.login}ajax-login/"
  if isString form then form = $ "##{form}"

  formLoader form

  ajaxSubmit url, form, (result) ->
    formLoader form, true

    form
    .find '.validate-error-show'
    .removeClass 'validate-error-show'
    .addClass 'validate-error-hide'

    if result.bStateError
      form
      .find '.validate-error-login'
      .removeClass 'validate-error-hide'
      .addClass 'validate-error-show'
      .html result.sMsg
    else
      if result.sMsg then notice null, result.sMsg
      if result.sUrlRedirect then window.location = result.sUrlRedirect

formLoader = (form, bHide) ->
  forEach form.find('input[type="text"], input[type="password"]'), (node) ->
    $(node).toggleClass 'loader', bHide

reminder = (form) ->
  url = "#{router.login}ajax-reminder/"
  if isString form then form = $ "##{form}"

  formLoader form

  ajaxSubmit url, form, (result) ->
    formLoader form, true

    form
    .find '.validate-error-show'
    .removeClass 'validate-error-show'
    .addClass 'validate-error-hide'

    if result.bStateError
      form
      .find '.validate-error-reminder'
      .removeClass 'validate-error-hide'
      .addClass 'validate-error-show'
      .text result.sMsg
    else
      form.find('input').val ''
      if result.sMsg then notice null, result.sMsg
      if result.sUrlRedirect then window.location = result.sUrlRedirect

reactivation = (form) ->
  url = "#{router.login}ajax-reactivation/"
  if isString form then form = $ "##{form}"

  ajaxSubmit url, form, (result) ->

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
  url = "#{router.people}ajax-search/"
  formLoader form

  ajaxSubmit url, form, (result) ->
    formLoader form, true

    searchList = $ '#users-list-search'
    searchOrig = $ '#users-list-original'

    searchList.toggle not result.bStateError
    searchOrig.toggle result.bStateError
    unless result.bStateError then searchList.html result.sText


searchUsersThrottled = throttle searchUsers, 750


searchUsersByPrefix = (sPrefix, obj) ->
  obj = $(obj)
  url = "#{router.people}ajax-search/"
  params =
    user_login: sPrefix
    isPrefix: 1

  $('#search-user-login').addClass 'loader'

  ajax url, params, (result) ->
    $('#search-user-login').removeClass 'loader'

    $('#user-prefix-filter')
    .find '.active'
    .removeClass 'active'

    obj.parent().addClass 'active'

    searchList = $ '#users-list-search'
    searchOrig = $ '#users-list-original'

    searchList.toggle not result.bStateError
    searchOrig.toggle result.bStateError
    unless result.bStateError then searchList.html result.sText

  false


followToggle = (obj, iUserId) ->
  if $(obj).hasClass('followed')
    unsubscribe iUserId
    $(obj).toggleClass('followed').text lang.get('profile_user_follow')
  else
    subscribe iUserId
    $(obj).toggleClass('followed').text lang.get('profile_user_unfollow')
  false

module.exports = {
  login
  reactivation
  registration
  reminder
  searchUsersThrottled
  searchUsersByPrefix
  validateRegistrationField
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