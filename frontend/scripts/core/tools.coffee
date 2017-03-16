###*
# Вспомогательные функции
###
$ = require 'jquery'
{delay, reduce, assign} = require 'lodash'

{notice, error} = require "./messages.coffee"
{ajax, ajaxSubmit} = require "./ajax.coffee"
routes = require("lib/routes").default

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

youtube = (str) ->
  unless str then return

  shortcode = /youtube:\/\/|https?:\/\/youtu\.be\//g
  if shortcode.test str
    shortcodeid = str.split(shortcode)[1]
    return shortcodeid

  inlinev = /\/v\/|\/vi\//g
  if inlinev.test str
    inlineid = str.split(inlinev)[1]
    return inlineid

  parameterv = /v=|vi=/g
  if parameterv.test str
    arr = str.split parameterv
    return arr[1].split('&')[0]

  embedreg = /\/embed\//g
  if embedreg.test str
    embedid = str.split(embedreg)[1]
    return embedid

  userreg = /\/user\//g
  if userreg.test str
    elements = str.split '/'
    return elements.pop()

  attrreg = /\/attribution_link\?.*v%3D([^%&]*)(%26|&|$)/
  if attrreg.test str
    return str.match(attrreg)[1]

vimeo = (str) ->
  unless str then return
  if str.indexOf('#') > -1
    strNew = str.split('#')[0]
  else
    strNew = str
  if /https?:\/\/vimeo\.com\/[0-9]+$|https?:\/\/player\.vimeo\.com\/video\/[0-9]+$/igm.test strNew
    arr = strNew.split '/'
    if arr && arr.length
      return arr.pop()

dailymotion = (str) ->
  unless str then return

  shortcode = /dai\.ly\//
  if shortcode.test str
    return str.split(shortcode)[1]

  video = /dailymotion\.com\/video\//
  if video.test str
    return str.split(video)[1].split('_')[0]

coub = (str) ->
  unless str then return

  view = /\/view\//
  if view.test str
    return str.split(view)[1]

  embed = /\/embed\//
  if embed.test str
    return str.split(embed)[1].split("?")[0]

rutube = (str) ->
  unless str then return

  embed = /\/embed\//
  if embed.test str
    return str.split(embed)[1]

  video = /\/video\//
  if video.test str
    return str.split(video)[1].split("/")[0]

contentMediaParser = (oldText) ->
  unless oldText then return
  temp = document.createElement 'temp'

  if /<video>|<iframe/i.test oldText
    temp.innerHTML = oldText
    video = temp.querySelectorAll "video, iframe"
    if video.length
      i = video.length
      while i--
        if video[i].nodeName == "VIDEO"
          url = video[i].textContent
        else
          url = video[i].getAttribute "src"
          if !url
            url = video[i].dataset.src
        if !url
          video[i].outerHTML = ''
          continue
        if /youtube|youtu\.be/.test url
          src = '//www.youtube.com/embed/' + youtube url
        else if /vimeo/.test url
          src = '//player.vimeo.com/video/' + vimeo url
        else if /dailymotion|dai\.ly/.test url
          src = '//www.dailymotion.com/embed/video/' + dailymotion url
        else if /coub\.com/.test url
          src = '//coub.com/embed/' + coub url
        else if /rutube/.test url
          src = '//rutube.ru/video/embed/' + rutube url
        else if video[i].nodeName == "IFRAME"
          continue
        if src
          video[i].outerHTML = '<iframe width="560" height="310" src="'+src+'" frameborder="0" allowfullscreen="1"></iframe>'
        else
          video[i].outerHTML = ''
    newText = temp.innerHTML
  else
    newText = oldText

  if newText.match /spoiler-body/i
    temp.innerHTML = newText
    spoilers = temp.getElementsByClassName "spoiler"
    if spoilers.length
      i = spoilers.length
      while i--

        # Убираем ифреймы из заголовка
        # Нет рутубу вне спойлеров
        badMedia = temp.querySelectorAll ".spoiler-title iframe, iframe[src*=rutube]"
        if badMedia.length
          j = badMedia.length
          while j--
            badMedia[j].outerHTML = ""

        media = spoilers[i].querySelectorAll ".spoiler-body img, iframe"
        if media.length
          j = media.length
          while j--
            if media[j].getAttribute "src"
              media[j].dataset.src = media[j].getAttribute "src"
              media[j].setAttribute "src", ""
          spoilers[i].classList.add 'spoiler-media'

      newText = temp.innerHTML

  else return newText
  temp.outerHTML = ''
  return newText

module.exports = {registry, textPreview, showPinkie, prepareJSON, uploadImg, spoilerHandler, contentRemoveBadChars, contentMediaParser}
