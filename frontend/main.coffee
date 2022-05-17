{assign} = require "lodash"

window.ls = {}
window.jQuery = require "jquery" # TODO: remove

assign ls, require "core"
assign ls, require "app"

document.addEventListener "DOMContentLoaded", require("init.coffee")
