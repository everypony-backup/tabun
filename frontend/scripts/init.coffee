$ = require "jquery"
require "jquery.ui"
require "jquery.jqmodal"
require "jquery.scrollto"
require "jquery.jcrop"
require "jquery.file"

{forEach, random} = require "lodash"

blocks = require "lib/blocks.coffee"
routes = require "lib/routes.coffee"
{showPinkie, registry} = require "core/tools.coffee"
autocomplete = require "core/autocomplete.coffee"

talk = require "app/talk.coffee"
toolbar = require "app/toolbar.coffee"

ReactDOM = require 'react-dom'
Login = require "core/login.coffee"

init = ->
  # Render React Login Component
  if el = document.getElementById 'window_login_form'
    loginComponent = ReactDOM.render Login(
      isModal: true)
    , el

  ['reminder', 'registration', 'enter'].map (tab) ->
    if el = document.getElementById 'action_' + tab
      ReactDOM.render Login(
        isModal: false
        initiallyHidden: false
        hasNavigation: false
        isLabeled: true
        initialTab: tab
      ), el

  # Bind login handlers
  $('.js-registration-form-show').click (e) ->
    e.preventDefault()
    loginComponent.show 'registration'
  $('.js-login-form-show').click (e) ->
    e.preventDefault()
    loginComponent.show 'enter'

  # Popups
  $('#blog_delete_form').jqm trigger: '#blog_delete_show', toTop: true
  $('#add_friend_form').jqm trigger: '#add_friend_show', toTop: true
  $('#window_upload_img').jqm()
  $('#favourite-form-tags').jqm()
  $('#modal_write').jqm trigger: '.js-write-window-show'
  $('#foto-resize').jqm modal: true, toTop: true
  $('#avatar-resize').jqm modal: true, toTop: true
  $('#userfield_form').jqm toTop: true

  # Autocomplete
  autocomplete.add $(".autocomplete-tags-sep"), routes.tag.autocomplete, true
  autocomplete.add $(".autocomplete-tags"), routes.tag.autocomplete, false
  autocomplete.add $(".autocomplete-users-sep"), routes.people.autocomplete, true
  autocomplete.add $(".autocomplete-users"), routes.people.autocomplete, false

  # Blocks
  blocks.init 'stream', group_items: true, group_min: 3
  blocks.init 'blogs'
  blocks.initSwitch 'tags'
  blocks.initSwitch 'upload-img'
  blocks.initSwitch 'favourite-topic-tags'
  blocks.initSwitch 'popup-login'

  # Datepicker
  $('.date-picker').datepicker
    dateFormat: 'dd.mm.yy'
    dayNamesMin: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']
    monthNames: ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь']
    firstDay: 1

  # Tag search
  $('.js-tag-search-form').submit ->
    val = $(this).find('.js-tag-search').val()
    if val
      window.location = "#{routes.tag.main}#{encodeURIComponent(val)}/"
    false

  # Talk
  $('#friends input:checkbox').on 'change', ->
    talk.toggleRecipient $("##{@.id}_label").text(), @.checked

  $('#friend_check_all').on 'click', ->
    forEach $('#friends input:checkbox'), (item) ->
      talk.toggleRecipient $("#{item.id}_label").text(), true
      item.checked = true
    false

  $('#friend_uncheck_all').on 'click', ->
    forEach $('#friends input:checkbox'), (item) ->
      talk.toggleRecipient $("#{item.id}_label").text(), false
      item.checked = false
    false

  $('#black_list_block').on 'click', 'a.delete', ->
    talk.removeFromBlackList @
    false

  $('#speaker_list_block').on 'click', 'a.delete', ->
    talk.removeFromTalk @, $('#talk_id').val()
    false
  
  talk.toggleSearchForm = ->
    $('.talk-search').toggleClass 'opened'
    false

  # Toolbar
  toolbar.init()

  # Pinkie Pie
  if random(1000) < 5 then showPinkie random 150, 1500

  # Spoilers
  $(document).on 'click', '.spoiler-title', ({target}) ->
    $e = $('.spoiler-body', $(target).closest('.spoiler')).eq(0)
    if $e.css('display') == 'none'
      $e.css 'display', 'block'
    else
      $e.hide 'normal'

  # Help-tags link
  $('.js-tags-help-link').on 'click', ({target}) ->
    helpTargetId = registry.get('tags-help-target-id')
    unless helpTargetId
      return false

    helpTarget = $ "##{helpTargetId}"
    unless helpTarget.length
      return false

    str = if target.dataset.insert? then target.dataset.insert else target.textContent
    $.markItUp target: target, replaceWith: str

  if window.location.pathname.match "settings/profile"
    (($) ->
      $('#foto-upload').file({ name:'foto' }).choose (e, input) ->
        ls.user.uploadFoto null, input
      $('#avatar-upload').file({ name:'avatar' }).choose (e, input) ->
        ls.user.uploadAvatar null, input
    ) jQuery

module.exports = init