require "./styles.styl"
{assign} = require "lodash"

window.ls = {}

assign ls, require("./scripts/ajax.coffee") # TODO: internal
ls.msg = require "./scripts/messages.coffee" # TODO: internal

ls.tools = require "./scripts/tools.coffee"
ls.registry = require "./scripts/registry.coffee" # TODO: move to tools
ls.lang = require "./scripts/lang.coffee"
ls.timer = require "./scripts/timer.coffee"
ls.autocomplete = require "./scripts/autocomplete.coffee"