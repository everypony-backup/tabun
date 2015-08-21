$ = require "jquery"
{forEach} = require "lodash"


iCurrentTopic = -1


goNextTopic = ->
  iCurrentTopic++
  topic = $(".js-topic:eq('#{iCurrentTopic}')")
  if topic.length
    $.scrollTo topic, 500
  else
    iCurrentTopic = $('.js-topic').length - 1
    # переход на следующую страницу
    page = $('.js-paging-next-page')
    if page.length and page.attr('href')
      window.location = page.attr('href') + '#goTopic=0'
  false


goPrevTopic = ->
  iCurrentTopic--
  if iCurrentTopic < 0
    iCurrentTopic = 0
    # на предыдущую страницу
    page = $('.js-paging-prev-page')
    if page.length and page.attr('href')
      window.location = page.attr('href') + '#goTopic=last'
  else
    topic = $(".js-topic:eq('#{iCurrentTopic}')")
    if topic.length
      $.scrollTo topic, 500
  false

init = ->
  vars = []
  hash = undefined
  hashes = window.location.hash.replace('#', '').split('&')
  i = 0
  while i < hashes.length
    hash = hashes[i].split('=')
    vars.push hash[0]
    vars[hash[0]] = hash[1]
    i++
  if vars.goTopic != undefined
    if vars.goTopic == 'last'
      iCurrentTopic = $('.js-topic').length - 2
    else
      iCurrentTopic = parseInt(vars.goTopic) - 1
    goNextTopic()

  # Up/down
  $('#up-switch').on 'click', -> $.scrollTo 0, 1000
  $('#down-switch').on 'click', -> $.scrollTo document.body.clientHeight, 1000

  # Wide Mode
  $('#widemode-switch').on 'click', -> $('body').toggleClass 'widemode'

  # Despoil
  $('#despoil').on 'click', ->
    forEach $('.spoiler-body'), (node) ->
      node.style.display = 'block'

module.exports = {init, goPrevTopic, goNextTopic}