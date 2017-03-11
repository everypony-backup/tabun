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

spoilerHandler = (target, action) ->
  unless target then return
  if action == 'despoil'
    style = 'block'
  else
    style = 'none'
  i = target.length
  while i--
    unless target[i].children[1] then continue
    if action == 'toggle'
      if target[i].children[1].style.display == 'block'
        style = 'none'
      else
        style = 'block'
    if style == 'block'
      if target[i].classList.contains "spoiler-media"
        target[i].children[1].innerHTML = target[i].children[1].innerHTML.replace /data-src="/gi, 'src="'
        target[i].classList.remove "spoiler-media"
    target[i].children[1].style.display = style
  return false

contentRemoveBadChars = (oldText) ->
  unless oldText then return
  newText = ''
  i = -1
  while ++i < oldText.length
    if oldText.codePointAt(i) < 65535
      newText += oldText[i]
    else
      newText += ' '
      i++
  return newText

contentMakeSpoilers = (oldText) ->
  unless oldText then return
  if oldText.match /spoiler-body/i
    temp = document.createElement 'temp'
    temp.innerHTML = oldText
    spoilers = temp.querySelectorAll ".spoiler:not(.spoiler-media)"
    if spoilers.length
      i = spoilers.length
      while i--
        if spoilers[i].children[1].innerHTML.match /src="/i
          spoilers[i].children[1].innerHTML = spoilers[i].children[1].innerHTML.replace /src="/gi, 'data-src="'
          spoilers[i].children[1].parentNode.classList.add 'spoiler-media'
      newText = temp.innerHTML
    else
      newText = oldText
    temp.outerHTML = ''
  else return oldText
  return newText

module.exports = {registry, textPreview, showPinkie, prepareJSON, uploadImg, spoilerHandler, contentRemoveBadChars, contentMakeSpoilers}
