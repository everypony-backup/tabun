###*
# Управление всплывающими сообщениями
###
notifier = require './notifier.coffee'

options =
  class_notice: 'n-notice'
  class_error: 'n-error'


module.exports =
  notice: (title, msg) ->
    notifier.broadcast title, msg, options.class_notice

  error: (title, msg) ->
    notifier.broadcast title, msg, options.class_error
