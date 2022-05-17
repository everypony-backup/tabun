markitup = require "lib/markitup.coffee"
comments = require "app/comments.coffee"


document.addEventListener "DOMContentLoaded", ->
  markitup.comments()
  comments.init()
