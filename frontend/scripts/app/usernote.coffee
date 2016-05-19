$ = require "jquery"

{ajax} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"
routes = require "lib/routes.coffee"


showNote = (sText) ->
  $('#usernote-note').hide()
  $('#usernote-button-add').show()
  $('#usernote-note-text').text sText

showForm = ->
  $('#usernote-button-add').hide()
  $('#usernote-note').hide()
  $('#usernote-form').show()
  textArea = $ '#usernote-form-text'
  textArea.val $('#usernote-form-text').val()
  textArea.focus()
  false

hideForm = ->
  $('#usernote-form').hide()
  sText = $('#usernote-form-text').val()
  showNote sText
  unless sText
    $('#usernote-button-add').show()
  false

save = (iUserId) ->
  url = routes.profile.addNote
  params =
    iUserId: iUserId
    text: $('#usernote-form-text').val()

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      showNote result.sText
  false


remove = (iUserId) ->
  url = routes.profile.removeNote
  params = iUserId: iUserId

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      showNote ''
  false


module.exports = {showForm, hideForm, save, remove}