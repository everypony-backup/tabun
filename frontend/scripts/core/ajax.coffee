$ = require "jquery"
require "jquery.form"
{notice, error} = require "./messages.coffee"


ajax = (url, params, callback, more) ->
  more = more or {}
  params = params or {}
  params.security_ls_key = window.LIVESTREET_SECURITY_KEY

  $.each params, (k, v) ->
    if typeof v == 'boolean'
      params[k] = if v then 1 else 0

  if url.indexOf('http://') != 0 and url.indexOf('https://') != 0 and url.indexOf('/') != 0
    url = aRouter['ajax'] + url + '/'

  $.ajax
    type: more.type or 'POST'
    url: url
    data: params
    dataType: more.dataType or 'json'
    success: callback or ->
    error: more.error or ->
    complete: more.complete or ->


ajaxSubmit = (url, form, callback, more) ->
  more = more or {}

  if typeof form == 'string'
    form = $('#' + form)

  if url.indexOf('http://') != 0 and url.indexOf('https://') != 0 and url.indexOf('/') != 0
    url = aRouter['ajax'] + url + '/'

  form.ajaxSubmit
    type: 'POST'
    url: url
    dataType: more.dataType or 'json'
    data: security_ls_key: window.LIVESTREET_SECURITY_KEY
    success: callback or ->
    error: more.error or ->

ajaxUploadImg = (form, sToLoad) ->
  upl_window = $('#window_upload_img')
  btns = $('.main-upl-btn', upl_window)
  btns.attr('disabled', 'disabled').addClass('disabled').text 'Загрузка...'
  ajaxSubmit 'upload/image/', form, (data) ->
    if data.bStateError
      error data.sMsgTitle, data.sMsg
    else
      $.markItUp replaceWith: data.sText
      upl_window.find('input[type="text"], input[type="file"]').val ''
      upl_window.jqmHide()

  btns.removeAttr('disabled').removeClass('disabled').text 'Загрузить'

module.exports = {ajax, ajaxSubmit, ajaxUploadImg}
