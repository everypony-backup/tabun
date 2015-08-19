$ = require "jquery"
{forEach, merge} = require "lodash"

{ajax} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"

router = window.aRouter


isBusy = false
dateLast = null

subscribe = (iTargetUserId) ->
  url = "#{router.stream}subscribe/"
  params = id: iTargetUserId
  ajax url, params, (data) ->
    if data.bStateError
      error data.sMsgTitle, data.sMsg
    else
      notice data.sMsgTitle, data.sMsg

unsubscribe = (iId) ->
  url = "#{router.stream}unsubscribe/"
  params = id: iId
  ajax url, params, (data) ->
    unless data.bStateError
      notice data.sMsgTitle, data.sMsg


switchEventType = (iType) ->
  url = "#{router.stream}switchEventType/"
  params = 'type': iType
  ajax url, params, (data) ->
    unless data.bStateError
      notice data.sMsgTitle, data.sMsg


appendUser = ->
  sLogin = $('#stream_users_complete').val()
  unless sLogin
    return
  url = "#{router.stream}subscribeByLogin/"
  params = 'login': sLogin
  ajax url, params, (data) ->
    if data.bStateError
      return error data.sMsgTitle, data.sMsg

    $('#stream_no_subscribed_users').remove()
    checkbox = $("#strm_u_#{data.uid}")
    if checkbox.length
      if checkbox.attr('checked')
        error lang.get('error'), lang.get('stream_subscribes_already_subscribed')
      else
        checkbox.attr 'checked', 'on'
        notice data.sMsgTitle, data.sMsg
    else
      liElement = $('<li><input type="checkbox" class="streamUserCheckbox input-checkbox" id="strm_u_' + data.uid + '" checked="checked" onClick="if ($(this).get(\'checked\')) {ls.stream.subscribe(' + data.uid + ')} else {ls.stream.unsubscribe(' + data.uid + ')}" /> <a href="' + data.user_web_path + '">' + data.user_login + '</a></li>')
      $('#stream_block_users_list').append liElement
      notice data.sMsgTitle, data.sMsg
      $('#strm_u_' + data.uid).parent().find('a').before('<a href="' + data.user_web_path + '"><img src="' + data.user_avatar_48 + '"  class="avatar" /></a> ')


more = (url, extra_params={}) ->
  if isBusy
    return
  lastId = $('#stream_last_id').val()
  unless lastId
    return
  selLoad = $ '#stream_get_more'
  selLoad.addClass 'stream_loading'
  isBusy = true
  url = "#{router.stream}#{url}/"
  params =
    last_id: lastId
    date_last: dateLast

  ajax url, merge(params, extra_params), (data) ->
    unless data.bStateError and data.events_count
      $('#stream-list').append data.result
      $('#stream_last_id').attr 'value', data.iStreamLastId
    unless data.events_count
      selLoad.hide()
    selLoad.removeClass 'stream_loading'
    isBusy = false

getMore = ->
  more "get_more"

getMoreAll = ->
  more "get_more_all"

getMoreByUser = (iUserId) ->
  more "get_more_user", user_id: iUserId


module.exports = {
  appendUser
  getMore
  getMoreAll
  getMoreByUser
  subscribe
  unsubscribe
  switchEventType
}