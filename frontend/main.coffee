require "./styles.styl"
{assign} = require "lodash"

window.ls = {}

assign ls, require "core"
assign ls, require "app"
assign ls, require "core/ajax.coffee" # TODO: internal

document.addEventListener "DOMContentLoaded", require("init.coffee")