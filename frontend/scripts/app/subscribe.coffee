$ = require "jquery"
{ajax} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"

router = window.aRouter

toggle = (sTargetType, iTargetId, sMail, iValue) ->
  url = "#{router.subscribe}ajax-subscribe-toggle/"
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