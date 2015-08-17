$ = require "jquery"
{assign, debounce} = require "lodash"
{ajax} = require "core/ajax.coffee"
{error} = require "core/messages.coffee"

router = window.aRouter

options =
  active: 'active'
  loader: require("../../images/loader-circle.gif")
  type:
    stream_comment: url: "#{router.ajax}stream/comment/"
    stream_topic: url: "#{router.ajax}stream/topic/"
    blogs_top: url: "#{router.ajax}blogs/top/"
    blogs_join: url: "#{router.ajax}blogs/join/"
    blogs_self: url: "#{router.ajax}blogs/self/"


showProgress = (content) ->
  ###*
  * Отображение процесса загрузки
  ###
  content.height content.height()
  content.empty().css
    'background': "url(#{options.loader}) no-repeat center top"
    'min-height': 70

onLoad = (content, result) ->
  ###*
  * Обработка результатов загрузки
  ###
  content.empty().css
    'background': 'none'
    'height': 'auto'
    'min-height': 0
  if result.bStateError
    error null, result.sMsg
  else
    content.html result.sText

load = (obj, block, params) ->
  ###*
  * Метод загрузки содержимого блока
  ###
  type = $(obj).data 'type'
  unless type
    return
  type = "#{block}_#{type}"
  params = assign {}, options.type[type].params or {}, params or {}
  content = $(".js-block-#{block}-content")

  showProgress content

  $(".js-block-#{block}-item").removeClass options.active
  $(obj).addClass options.active

  ajax options.type[type].url, params, (result) -> onLoad content, result


getCurrentItem = (block) ->
  block = $(".js-block-#{block}-nav")
  selector = ".js-block-#{block}-item.#{options.active}"

  if block.is(':visible')
    block.find selector
  else
  $(".js-block-#{block}-dropdown-items").find selector


###*
# Переключает вкладки в блоке, без использования Ajax
# @param obj
# @param block
###
switchTab = (obj, block) ->
  ###*
  # Если вкладку передаем как строчку - значение data-type
  ###
  selItem = $(".js-block-#{block}-item")
  if typeof obj == 'string'
    selItem.each (k, v) ->
      if $(v).data('type') == obj
        obj = v
  ###*
  # Если не нашли такой вкладки
  ###
  if typeof obj == 'string'
    return false

  selItem.removeClass options.active
  $(obj).addClass options.active

  selContent = $(".js-block-#{block}-content")
  selContent.hide()
  selContent.each (k, v) ->
    if $(v).data('type') == $(obj).data('type')
      $(v).show()
  true

initSwitch = (block) ->
  $(".js-block-#{block}-item").click ->
    switchTab this, block
    false

init = (block, params) ->
  params ?= {}
  $(".js-block-#{block}-item").click ->
    load this, block
    false

  if params.group_items
    initNavigation block, params.group_min

  $(".js-block-#{block}-update").click ->
    $(@).addClass 'active'
    load getCurrentItem(block), block
    setTimeout(
      -> $(@).removeClass 'active'
      600
    )

initNavigation = (block, count) ->
  count ?= 3
  nav = $(".js-block-#{block}-nav")
  dropdown = $(".js-block-#{block}-dropdown")

  if nav.find('li').length >= count
    nav.hide()
    dropdown.show()

    # Dropdown
    trigger = $(".js-block-#{block}-dropdown-trigger")
    menu = $(".js-block-#{block}-dropdown-items")

    menu.appendTo('body').css 'display': 'none'
    trigger.click ->
      pos = $(@).offset()
      menu.css
        'left': pos.left
        'top': pos.top + 30
        'z-index': 2100
      menu.slideToggle()
      $(@).toggleClass 'opened'
      false
    menu.find('a').click ->
      trigger.removeClass('opened').find('a').text $(@).text()
      menu.slideToggle()

    # Hide menu
    $(document).click ->
      trigger.removeClass 'opened'
      menu.slideUp()

    $('body').on 'click', ".js-block-#{block}-dropdown-trigger, .js-block-#{block}-dropdown-items", (e) ->
      e.stopPropagation()

    $(window).resize debounce ->
      menu.css 'left': trigger.offset().left

  else
    # Transform nav to dropdown
    nav.show()
    dropdown.hide()


module.exports = {load, init, getCurrentItem, switchTab, initSwitch}
