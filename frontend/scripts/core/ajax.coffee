$ = require "jquery"
require "jquery.form"
{forEach, isBoolean, isString, startsWith} = require "lodash"
{notice, error} = require "./messages.coffee"

router = window.aRouter

_normalize_url = (url) ->
  unless (
    startsWith(url, 'http://') or
      startsWith(url, 'https://') or
      startsWith(url, '//') or
      '/' not in url
  )
    "#{router.ajax}#{url}/"
  else
    url

ajax = (url, params, callback, more) ->
  more ?= {}
  params ?= {}
  params.security_ls_key = window.LIVESTREET_SECURITY_KEY

  forEach params, (value, key) ->
    if isBoolean value
      params[key] = if value then 1 else 0

  $.ajax
    type: more.type or 'POST'
    url: _normalize_url url
    data: params
    dataType: more.dataType or 'json'
    success: callback or ->
    error: more.error or ->
    complete: more.complete or ->


ajaxSubmit = (url, form, callback, more={}) ->

  form.ajaxSubmit
    type: 'POST'
    url: _normalize_url url
    dataType: more.dataType or 'json'
    data: security_ls_key: window.LIVESTREET_SECURITY_KEY
    success: callback or ->
    error: more.error or ->

ajaxUploadImg = (form) ->
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
