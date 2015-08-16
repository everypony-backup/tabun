require "./styles.styl"
{assign} = require "lodash"

window.ls = {}

assign ls, require "./scripts/core"
assign ls, require "./scripts/core/ajax.coffee" # TODO: internal
ls.blocks = require "./scripts/blocks.coffee" # TODO: internal

require("./scripts/template.coffee")()