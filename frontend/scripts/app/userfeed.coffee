$ = require "jquery"

{ajax} = require "core/ajax.coffee"
lang = require "core/lang.coffee"
{error, notice} = require "core/messages.coffee"

router = window.aRouter


isBusy = false

subscribe = (sType, iId) ->
  url = "#{router.feed}subscribe/"
  params =
    'type': sType
    'id': iId
    
  ajax url, params, (data) ->
    unless data.bStateError
      notice data.sMsgTitle, data.sMsg


unsubscribe = (sType, iId) ->
  url = "#{router.feed}unsubscribe/"
  params =
    'type': sType
    'id': iId
    
  ajax url, params, (data) ->
    unless data.bStateError
      notice data.sMsgTitle, data.sMsg
      

appendUser = ->
  sLogin = $('#userfeed_users_complete').val()
  unless sLogin
    return
  url = "#{router.feed}subscribeByLogin/"
  params = 'login': sLogin

  ajax url, params, (data) ->
    if data.bStateError
      error data.sMsgTitle, data.sMsg
    else
      $('#userfeed_no_subscribed_users').remove()
      checkbox = $ "#usf_u_#{data.uid}"
      if checkbox.length
        if checkbox.attr('checked')
          error data.lang_error_title, data.lang_error_msg
        else
          checkbox.attr 'checked', 'on'
          notice data.sMsgTitle, data.sMsg
      else
        liElement = $('<li><input type="checkbox" class="userfeedUserCheckbox input-checkbox" id="usf_u_' + data.uid + '" checked="checked" onClick="if ($(this).get(\'checked\')) {ls.userfeed.subscribe(\'users\',' + data.uid + ')} else {ls.userfeed.unsubscribe(\'users\',' + data.uid + ')}" /><a href="' + data.user_web_path + '">' + data.user_login + '</a></li>')
        $('#userfeed_block_users_list').append liElement
        notice data.sMsgTitle, data.sMsg

getMore = ->
  if isBusy
    return
  lastId = $('#userfeed_last_id').val()
  unless lastId
    return

  $('#userfeed_get_more').addClass 'userfeed_loading'
  isBusy = true

  url = "#{router.feed}get_more/"
  params = 'last_id': lastId

  ajax url, params, (data) ->
    unless data.bStateError and data.topics_count
      $('#userfeed_loaded_topics').append data.result
      $('#userfeed_last_id').attr 'value', data.iUserfeedLastId
    unless data.topics_count
      $('#userfeed_get_more').hide()

    isBusy = false
    $('#userfeed_get_more').removeClass 'userfeed_loading'


module.exports = {subscribe, unsubscribe, appendUser, getMore}