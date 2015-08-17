###*
# Вспомогательные функции
###
$ = require 'jquery'
{notice, error} = require "./messages.coffee"
{ajax} = require "./ajax.coffee"

_registry = {}

tools =
  registry:
    get: (sName) ->
      _registry[sName]

    set: (sName, data) ->
      _registry[sName] = data

  ucfirst: (str) ->
    f = str.charAt(0).toUpperCase()
    f + str.substr(1, str.length - 1)

  checkAll: (cssclass, checkbox, invert) ->
    $('.' + cssclass).each (index, item) ->
      if invert
        $(item).attr 'checked', !$(item).attr('checked')
      else
        $(item).attr 'checked', $(checkbox).attr('checked')


  textPreview: (textId, save, divPreview) ->
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

module.exports = tools