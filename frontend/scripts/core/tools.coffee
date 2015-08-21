###*
# Вспомогательные функции
###
$ = require 'jquery'
{delay} = require 'lodash'

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

module.exports = {registry, textPreview, showPinkie}