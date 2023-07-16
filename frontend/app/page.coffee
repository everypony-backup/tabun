$ = require "jquery"

{ajaxSubmit} = require "core/ajax.coffee"
{error} = require "core/messages.coffee"
routes = require("lib/routes").default


preview = (form, preview) ->
  form = $ "##{form}"
  preview = $ "##{preview}"
  url = routes.preview.topic

  ajaxSubmit url, form, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      preview.show().html result.sText


module.exports = {preview}
