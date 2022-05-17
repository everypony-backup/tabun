$ = require "jquery"
require "jquery.form"
{Set} = require "immutable"
{forEach, isBoolean, flatten, reduce, values} = require "lodash"
{gettext} = require "core/lang.coffee"
{notice, error} = require "core/messages.coffee"
routes = require("lib/routes").default


allowedUrls = Set flatten reduce(
  values routes
  (acc, x) ->
    if typeof x == "string"
      acc.push x
    else
      acc.push values x
    acc
  []
)
security_ls_key = window.LIVESTREET_SECURITY_KEY
prefix = '' # debug env

_error = -> return error gettext("network_error"), gettext("data_not_send")

ajax = (url, params={}, callback, complete, err) ->
  unless allowedUrls.contains url
    return error gettext("incorrect_url")
  params.security_ls_key = security_ls_key

  forEach params, (value, key) ->
    if isBoolean value
      params[key] = if value then 1 else 0

  $.ajax
    type: 'POST'
    url: prefix + url
    data: params
    dataType: 'json'
    success: callback or ->
    error: err or _error
    complete: complete or ->


ajaxSubmit = (url, form, callback, error) ->

  form.ajaxSubmit
    type: 'POST'
    url: prefix + url
    dataType: 'json'
    data: {security_ls_key}
    success: callback or ->
    error: error or _error

module.exports = {ajax, ajaxSubmit}
