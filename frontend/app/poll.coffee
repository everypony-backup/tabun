$ = require "jquery"

lang = require "core/lang.coffee"
{ajax} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"
routes = require("lib/routes").default


vote = (idTopic, idAnswer) ->
  url = routes.vote.question
  params =
    idTopic: idTopic
    idAnswer: idAnswer
    
  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      notice null, result.sMsg
      $("#topic_question_area_#{idTopic}").html result.sText


addAnswer = ->
  if $('#question_list li').length > 20
    error null, lang.get 'topic_question_create_answers_error_max'
    return false

  newItem = $('#question_list li:first-child').clone()
  newItem.find('a').remove()
  removeAnchor = $('<a href="#"/>').text(lang.get('delete')).click (e) ->
    e.preventDefault()
    removeAnswer e.target

  newItem.appendTo('#question_list').append removeAnchor
  newItem.find('input').val ''


removeAnswer = (obj) ->
  $(obj).parent('li').remove()
  false

switchResult = (obj, iTopicId) ->
  selOrig = $ "#poll-result-original-#{iTopicId}"
  selSort = $ "#poll-result-sort-#{iTopicId}"

  if selSort.css('display') == 'none'
    selOrig.hide()
    selSort.show()
  else
    selSort.hide()
    selOrig.show()

  $(obj).toggleClass 'active'
  false

module.exports = {vote, addAnswer, removeAnswer, switchResult}
