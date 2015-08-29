$ = require "jquery"
require "jquery.form"
{gettext} = require "core/lang.coffee"
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

_error = -> return error gettext("network_error"), gettext("data_not_send")

ajax = (url, params, callback, error, complete) ->
  params ?= {}
  params.security_ls_key = window.LIVESTREET_SECURITY_KEY

  forEach params, (value, key) ->
    if isBoolean value
      params[key] = if value then 1 else 0

  $.ajax
    type: 'POST'
    url: _normalize_url url
    data: params
    dataType: 'json'
    success: callback or ->
    error: error or _error
    complete: complete or ->


ajaxSubmit = (url, form, callback, error) ->

  form.ajaxSubmit
    type: 'POST'
    url: _normalize_url url
    dataType: 'json'
    data: security_ls_key: window.LIVESTREET_SECURITY_KEY
    success: callback or ->
    error: error or _error

module.exports = {ajax, ajaxSubmit}
