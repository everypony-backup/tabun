$ = require "jquery"
{ajax} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"
routes = require("lib/routes").default


toggle = (sTargetType, iTargetId, sMail, iValue) ->
  url = routes.subscribe.toggle
  params =
    target_type: sTargetType
    target_id: iTargetId
    mail: sMail
    value: iValue
  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      notice null, result.sMsg
  false

module.exports = {toggle}
