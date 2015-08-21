###*
# Вспомогательные функции
###
$ = require 'jquery'
{delay, reduce} = require 'lodash'

{notice, error} = require "./messages.coffee"
{ajax} = require "./ajax.coffee"

_registry = {}

registry =
  get: (sName) ->
    _registry[sName]

  set: (sName, data) ->
    _registry[sName] = data

textPreview = (textId, save, divPreview) ->
  text = $('#' + textId).val()
  ajaxUrl = aRouter['ajax'] + 'preview/text/'
  ajaxOptions =
    text: text
    save: save
  ajax ajaxUrl, ajaxOptions, (result) ->
    if !result
      error 'Error', 'Please try again later'
    if result.bStateError
      error result.sMsgTitle or 'Error', result.sMsg or 'Please try again later'
    else
      if !divPreview
        divPreview = 'text_preview'
      elementPreview = $('#' + divPreview)
      if elementPreview.length
        elementPreview.html result.sText

showPinkie = (time) ->
  pinkie = $('<img>')
  pinkie.attr
    src: require("../../images/pinkamena.png")
    style: 'display:block;position:fixed;left:0px;bottom:0px;z-index:100;height:100%;'
  $('body').append pinkie
  delay(
    -> pinkie.remove()
    time
  )

prepareJSON = (raw_form) ->
  reduce(
    raw_form.serializeArray(),
    (result, item) ->
      result[item.name] = item.value
      result
    {}
  )

module.exports = {registry, textPreview, showPinkie, prepareJSON}