$ = require "jquery"
{forEach, throttle} = require "lodash"
{spoilerHandler} = require "core/tools.coffee"

iCurrentTopic = -1


goNextTopic = ->
  iCurrentTopic++
  topic = $(".js-topic:eq('#{iCurrentTopic}')")
  if topic.length
    if UI.smothScroll
      $.scrollTo topic, 500
    else
      window.scrollBy 0,topic[0].getClientRects()[0].top
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
      if UI.smothScroll
        $.scrollTo topic, 500
      else
        window.scrollBy 0,topic[0].getClientRects()[0].top
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
  $("#toolbar").show()

  # Up/down
  $('#up-switch').on 'click', ->
    if UI.smothScroll
      $.scrollTo 0, 1000
    else
      window.scrollTo 0, 0
  $('#down-switch').on 'click', ->
    if UI.smothScroll
      $.scrollTo document.body.clientHeight, 1000
    else
      window.scrollTo 0, document.body.clientHeight

  # Wide Mode
  $('#widemode-switch').on 'click', -> $('body').toggleClass 'widemode'

  # Despoil
  $('#despoil').on 'click', ->
    if UI.despoilOnlyArticle
      target = $('article .spoiler')
    else
      target = $('.spoiler')
    if this.textContent.trim() == 'Despoil'
      this.textContent = 'Spoil'
      action = 'despoil'
    else
      this.textContent = 'Despoil'
      action = 'spoil'
    spoilerHandler target, action

  #goPrev, goNext
  $('.toolbar-topic-prev').on 'click', ->
    ls.toolbar.goPrevTopic()
  $('.toolbar-topic-next').on 'click', ->
    ls.toolbar.goNextTopic()

module.exports = {init, goPrevTopic, goNextTopic}
