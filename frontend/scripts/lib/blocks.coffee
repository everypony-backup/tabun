$ = require "jquery"
{assign, delay, first, throttle, isString, forEach} = require "lodash"
{ajax} = require "core/ajax.coffee"
{error} = require "core/messages.coffee"
routes = require("lib/routes").default

options =
  active: 'active'
  type:
    stream_comment: url: routes.stream.comment
    stream_topic: url: routes.stream.topic
    blogs_top: url: routes.blogs.top
    blogs_join: url: routes.blogs.joined
    blogs_self: url: routes.blogs.self


showProgress = (content) ->
  ###*
  * Отображение процесса загрузки
  ###

  content.empty().removeClass("block-loaded").addClass("block-loading")


onLoad = (content, result) ->
  ###*
  * Обработка результатов загрузки
  ###
  content.empty().removeClass("block-loading").addClass("block-loaded")
  if result.bStateError
    return error null, result.sMsg

  content.html result.sText

load = (obj, block, params) ->
  ###*
  * Метод загрузки содержимого блока
  ###
  unless obj.dataset.type
    return
  type = "#{block}_#{obj.dataset.type}"
  params = assign {}, options.type[type].params or {}, params or {}
  content = $(".js-block-#{block}-content")

  showProgress content

  $(".js-block-#{block}-item").removeClass options.active
  $(obj).addClass options.active

  ajax options.type[type].url, params, (result) -> onLoad content, result


getCurrentItem = (block) ->
  navBlock = $(".js-block-#{block}-nav")
  dropBlock = $(".js-block-#{block}-dropdown-items")
  selector = ".js-block-#{block}-item.#{options.active}"
  first if navBlock.is(':visible') then navBlock.find selector else dropBlock.find selector

###*
# Переключает вкладки в блоке, без использования Ajax
###
switchTab = (obj, block) ->
  ###*
  # Если вкладку передаем как строчку - значение data-type
  ###
  selItem = $(".js-block-#{block}-item")
  if isString obj
    forEach selItem, (node) ->
      if node.dataset.type == obj
        obj = node
  ###*
  # Если не нашли такой вкладки
  ###
  if isString obj
    return false

  selItem.removeClass options.active
  $(obj).addClass options.active

  selContent = $(".js-block-#{block}-content")
  selContent.hide()
  forEach selContent, (node) ->
    if node.dataset.type == obj.dataset.type
      $(node).show()
  true

initSwitch = (block) ->
  $(".js-block-#{block}-item").on "click", ({currentTarget}) ->
    switchTab currentTarget, block
    false

init = (block, params) ->
  params ?= {}
  $(".js-block-#{block}-item").on "click", ({currentTarget}) ->
    load currentTarget, block
    false

  if params.group_items
    initNavigation block, params.group_min

  $(".js-block-#{block}-update").on "click", ({currentTarget}) ->
    $(currentTarget).addClass 'active'
    load getCurrentItem(block), block
    delay(
      -> $(currentTarget).removeClass 'active'
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
    trigger.on "click", ({currentTarget}) ->
      pos = $(currentTarget).offset()
      menu.css
        'left': pos.left
        'top': pos.top + 30
        'z-index': 2100
      menu.slideToggle()
      $(target).toggleClass 'opened'
      false
    menu.find('a').on "click", ({currentTarget}) ->
      trigger.removeClass('opened').find('a').text $(currentTarget).text()
      menu.slideToggle()

    # Hide menu
    $(document).on "click", ->
      trigger.removeClass 'opened'
      menu.slideUp()

    $('body').on 'click', ".js-block-#{block}-dropdown-trigger, .js-block-#{block}-dropdown-items", (e) ->
      e.stopPropagation()

    $(window).resize throttle (-> menu.css 'left': trigger.offset().left), 300

  else
    # Transform nav to dropdown
    nav.show()
    dropdown.hide()


module.exports = {load, init, getCurrentItem, switchTab, initSwitch}
