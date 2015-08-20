require "./styles.styl"
{assign} = require "lodash"

window.ls = {}
window.jQuery = require "jquery" # TODO: remove

assign ls, require "core"
assign ls, require "app"
assign ls, require "core/ajax.coffee" # TODO: internal

document.addEventListener "DOMContentLoaded", require("init.coffee")