$ = require "jquery"
{forEach, debounce, isString} = require "lodash"

{ajax, ajaxSubmit} = require "core/ajax.coffee"
{gettext} = require "core/lang.coffee"
{notice, error} = require "core/messages.coffee"
{subscribe, unsubscribe} = require "app/stream.coffee"
routes = require("lib/routes").default


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


formLoader = (form, bHide) ->
  forEach form.find('input[type="text"], input[type="password"]'), (node) ->
    $(node).toggleClass 'loader', bHide

reactivation = () ->
  form = document.getElementById "reactivation-form"

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
}
