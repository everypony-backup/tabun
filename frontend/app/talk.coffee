$ = require "jquery"
{words, uniq, without, forEach} = require "lodash"

{ajax} = require "core/ajax.coffee"
lang = require "core/lang.coffee"
{error, notice} = require "core/messages.coffee"
routes = require("lib/routes").default


addToTalk = (idTalk) ->
  selTalk = $ '#talk_speaker_add'
  sUsers = selTalk.val()

  unless sUsers
    return false

  selTalk.val ''
  url = routes.talk.addUser
  params =
    users: sUsers
    idTalk: idTalk

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      forEach result.aUsers, (item) ->
        if item.bStateError
          notice null, item.sMsg
        else
          list = $ '#speaker_list'
          if list.length == 0
            list = $('<ul class="list" id="speaker_list"></ul>')
            $('#speaker_list_block').append list
          list.append $ """
            <li id="speaker_item_#{item.sUserId}_area">
              <a href="#{item.sUserLink}" class="user">#{item.sUserLogin}</a> - <a href="#" id="speaker_item_#{item.sUserId}" class="delete">Удалить</a>
            </li>
            """
  false


removeFromTalk = (link, idTalk) ->
  link = $(link)
  $("##{link.attr('id')}_area").fadeOut 500, ->
    $(@).remove()

  idTarget = link.attr('id').replace('speaker_item_', '')
  url = routes.talk.removeUser
  params =
    idTarget: idTarget
    idTalk: idTalk

  ajax url, params, (result) ->
    unless result
      error 'Error', 'Please try again later'
      link.parent('li').show()

    if result.bStateError
      error null, result.sMsg
      link.parent('li').show()
  false


addToBlackList = ->
  sUsers = $('#talk_blacklist_add').val()
  unless sUsers
    return false

  $('#talk_blacklist_add').val ''
  url = "ajaxaddtoblacklist/"
  params = users: sUsers

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      forEach result.aUsers, (index, item) ->
        if item.bStateError
          notice null, item.sMsg
        else
          list = $('#black_list')
          if list.length == 0
            list = $('<ul class="list" id="black_list"></ul>')
            $('#black_list_block').append list
          $('#black_list').append $ """
            <li id="blacklist_item_#{item.sUserId}_area">
              <a href="#" class="user">#{item.sUserLogin}</a> - <a href="#" id="blacklist_item_#{item.sUserId}" class="delete">#{lang.get 'delete'}</a>
            </li>
          """
  false


removeFromBlackList = (link) ->
  link = $(link)
  $("##{link.attr('id')}_area").fadeOut 500, ->
    $(@).remove()

  idTarget = link.attr('id').replace('blacklist_item_', '')
  url = routes.talk.unBlacklistUser
  params = idTarget: idTarget

  ajax url, params, (result) ->
     unless result
      error 'Error', 'Please try again later'
      link.parent('li').show()
    if result.bStateError
      error null, result.sMsg
      link.parent('li').show()
  false

toggleRecipient = (login, add) ->
  sel = $('#talk_users')
  to = words sel.val()
  if add
    to.push login
    result = uniq to
  else
    result = without to, login
  sel.val result.join ', '


clearFilter = ->
  sel = $ '#block_talk_search_content'
  sel.find('input[type="text"]').val ''
  sel.find('input[type="checkbox"]').removeAttr 'checked'
  false

removeTalks = ->
  if $('.form_talks_checkbox:checked').length == 0
    return false
  $('#form_talks_list_submit_del').val 1
  $('#form_talks_list_submit_read').val 0
  $('#form_talks_list').submit()
  false

makeReadTalks = ->
  if $('.form_talks_checkbox:checked').length == 0
    return false
  $('#form_talks_list_submit_read').val 1
  $('#form_talks_list_submit_del').val 0
  $('#form_talks_list').submit()
  false

checkAll = (cssclass, checkbox, invert) ->
  forEach $(".#{cssclass}"), (node) ->
    node.checked = if invert then not node.checked else checkbox.checked

module.exports = {
  addToTalk
  removeFromTalk
  addToBlackList
  toggleRecipient
  clearFilter
  removeTalks
  makeReadTalks
  checkAll
}
