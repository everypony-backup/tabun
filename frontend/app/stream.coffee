$ = require "jquery"
{merge} = require "lodash"

{ajax} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"

routes = require("lib/routes").default


isBusy = false
dateLast = null

subscribe = (iTargetUserId) ->
  url = routes.stream.subscribe
  params = id: iTargetUserId
  ajax url, params, (data) ->
    if data.bStateError
      error data.sMsgTitle, data.sMsg
    else
      notice data.sMsgTitle, data.sMsg

unsubscribe = (iId) ->
  url = routes.stream.unsubscribe
  params = id: iId
  ajax url, params, (data) ->
    unless data.bStateError
      notice data.sMsgTitle, data.sMsg


switchEventType = (iType) ->
  url = routes.stream.switchEventType
  params = 'type': iType
  ajax url, params, (data) ->
    unless data.bStateError
      notice data.sMsgTitle, data.sMsg


appendUser = ->
  sLogin = $('#stream_users_complete').val()
  unless sLogin
    return
  url = routes.stream.subscribeByLogin
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
  if isBusy then return
  selLoad = document.getElementsByClassName('stream-get-more')[0]
  lastId = selLoad.dataset.lastId
  unless lastId then return
  selLoad.classList.add 'stream_loading'
  isBusy = true
  params =
    last_id: lastId
    date_last: dateLast

  ajax url, merge(params, extra_params), (data) ->
    unless data.bStateError and data.events_count
      $('#stream-list').append data.result
      selLoad.dataset.lastId = data.iStreamLastId
    unless data.events_count
      selLoad.classList.add 'h-hidden'
    selLoad.classList.remove 'stream_loading'
    isBusy = false

getMore = ->
  more routes.stream.getMore

getMoreAll = ->
  more routes.stream.getMoreAll

getMoreByUser = (iUserId) ->
  more routes.stream.getMoreUser, user_id: iUserId


module.exports = {
  appendUser
  getMore
  getMoreAll
  getMoreByUser
  subscribe
  unsubscribe
  switchEventType
}
