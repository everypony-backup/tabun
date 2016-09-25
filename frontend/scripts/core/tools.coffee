###*
# Вспомогательные функции
###
$ = require 'jquery'
{delay, reduce, assign} = require 'lodash'

{notice, error} = require "./messages.coffee"
{ajax, ajaxSubmit} = require "./ajax.coffee"
routes = require "lib/routes.coffee"

_registry = {}

registry =
  get: (sName) ->
    _registry[sName]

  set: (sName, data) ->
    _registry[sName] = data

  loadJSON: (jsonData) ->
    assign(_registry, JSON.parse(jsonData))

textPreview = (textId, save, divPreview, fix=false) ->
  text = $('#' + textId).val()
  ajaxOptions =
    text: text
    save: save
    fix: fix
  ajax routes.preview.text, ajaxOptions, (result) ->
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
    src: "//files.everypony.ru/tabun/pinkamena.png"
    style: 'display:block;position:fixed;left:0px;bottom:0px;z-index:100;height:100%;'
  $('body').append pinkie
  delay(
    -> pinkie.remove()
    time
  )

prepareJSON = (raw_form) ->
  reduce(
    $(raw_form).serializeArray(),
    (result, item) ->
      result[item.name] = item.value
      result
    {}
  )

uploadImg = (formId) ->
  form = $ "##{formId}"
  upl_window = $('#window_upload_img')
  btns = $('.main-upl-btn', upl_window)
  btns.attr('disabled', 'disabled').addClass('disabled').text 'Загрузка...'
  ajaxSubmit routes.image.uploadImage, form, (data) ->
    if data.bStateError
      error data.sMsgTitle, data.sMsg
    else
      $.markItUp replaceWith: data.sText
      upl_window.find('input[type="text"], input[type="file"]').val ''
      upl_window.jqmHide()

  btns.removeAttr('disabled').removeClass('disabled').text 'Загрузить'


module.exports = {registry, textPreview, showPinkie, prepareJSON, uploadImg}
