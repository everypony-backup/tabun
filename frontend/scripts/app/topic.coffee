$ = require "jquery"

{ajaxSubmit} = require "core/ajax.coffee"
{error} = require "core/messages.coffee"

router = window.aRouter

preview = (form, preview) ->
  form = $ "##{form}"
  preview = $ "##{preview}"
  url = "#{router.ajax}preview/topic/"

  ajaxSubmit url, form, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      preview.show().html result.sText


module.exports = {preview}