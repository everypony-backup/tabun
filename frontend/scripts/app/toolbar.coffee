$ = require "jquery"
{forEach, throttle} = require "lodash"


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

recalculateToolbarPos = ->
  if $('#toolbar section').length
    if $(document).width() <= 1100
      unless $('#container').hasClass('no-resize')
        $('#container').addClass 'toolbar-margin'
      $('#toolbar').css
        'position': 'absolute'
        'right': 0
        'top': $(document).scrollTop() + 175
        'display': 'block'
    else
      $('#container').removeClass 'toolbar-margin'
      $('#toolbar').css
        'position': 'fixed'
        'right': 0
        'top': 175
        'display': 'block'

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
    if $(this).text().trim() == 'Despoil'
      $(this).text('Spoil')
      forEach $('.spoiler-body'), (node) ->
        node.style.display = 'block'
    else
      $(this).text('Despoil')
      forEach $('.spoiler-body'), (node) ->
        node.style.display = 'none'

  # Toolbar repositioning
  recalculateToolbarPos()
  $(window).on 'resize', throttle recalculateToolbarPos, 300
  $(window).on 'scroll', throttle (-> if $(document).width() <= 1100 then recalculateToolbarPos()), 300

module.exports = {init, goPrevTopic, goNextTopic}