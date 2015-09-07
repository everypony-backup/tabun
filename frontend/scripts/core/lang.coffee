{assign, forEach} = require "lodash"
Jed = require 'jed'

messages = {}

i18n = new Jed require "ru_RU/LC_MESSAGES/messages.po"


String::tr = (a, p) ->
  p = if typeof p == 'string' then p else ''
  s = this
  forEach a, (k) ->
    tk = if p then p.split('/') else []
    tk[tk.length] = k
    tp = tk.join('/')
    if typeof a[k] == 'object'
      s = s.tr(a[k], tp)
    else
      s = s.replace(new RegExp('%%' + tp + '%%', 'g'), a[k])
  s

module.exports =
  load: (loaded) ->
    assign messages, loaded

  get: (name, replace) ->
    if messages[name]
      value = messages[name]
      if replace
        value = value.tr(replace)
      value

  gettext: (message) -> i18n.gettext message

  ngettext: (single, plural, value) -> i18n.ngettext single, plural, value
