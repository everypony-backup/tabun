$ = require "jquery"
require "jquery.ui"
require "jquery.jqmodal"
require "jquery.scrollto"

{forEach, random} = require "lodash"

blocks = require "lib/blocks.coffee"
routes = require("lib/routes").default
{showPinkie, registry, spoilerHandler, contentRemoveBadChars, contentMediaParser, textPreview} = require "core/tools.coffee"
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
  if UI.showPinkie
    if random(1000) < 5 then showPinkie random 150, 1500

  # autoDespoil
  if UI.autoDespoil
    document.getElementById('UI-custom-style').textContent += '.comment-current .spoiler-gray{background-color:transparent;color: #777;}.comment-current .spoiler-gray img{filter: inherit;}'

  # Spoilers
  $(document).on 'click', '.spoiler-title', () ->
    spoilerHandler $(this).parent(), 'toggle'

  # Vote
  $(document).on 'click', ".vote-enabled .vote-item", () ->
    if this.dataset.direction != "0" || UI.voteNeutral
      ls.vote.vote this.dataset.target_id, this, this.dataset.direction, this.dataset.target_type

  # get votes
  $(document).on 'click', ".vote-info-enabled .vote-count", () ->
    ls.vote.getVotes this.dataset.target_id, this.dataset.target_type, this

  # favourite
  $(document).on 'click', ".favourite", () ->
    ls.favourite.toggle this.dataset.target_id, this, this.dataset.target_type

  # reactivation
    $("#reactivation-form-submit").disabled = false
    $("#reactivation-form-submit").on 'click', ->
      ls.user.reactivation()

  if window.location.pathname.match "settings/profile"
    $(document).ready () ->
      ls.geo.initSelect()
    $('#form-field-add').on 'click', ->
      ls.userfield.addFormField()
    $(document).on 'change', '#user-field-contact-contener select', ->
      ls.userfield.changeFormField this
    $(document).on 'click', '#user-field-contact-contener .icon-synio-remove', ->
      ls.userfield.removeFormField this
  else if window.location.pathname.match "settings/tuning"
    forEach $('.UI-checkbox'), (checkbox) ->
      if UI[checkbox.dataset.name]
        checkbox.checked = UI[checkbox.dataset.name]
    $('.UI-checkbox').on 'click', () ->
      window.localStorage.setItem("UI-"+this.dataset.name, this.checked)
  else if window.location.pathname.match "profile"
    $('#usernote_edit').on 'click', ->
      ls.usernote.showForm()
    $('#usernote_delete').on 'click', ->
      ls.usernote.remove(this.dataset.user_id)
    $('#usernote_save').on 'click', ->
      ls.usernote.save(this.dataset.user_id)
    $('#usernote_cancel').on 'click', ->
      ls.usernote.hideForm()
    $('#usernote-button-add').on 'click', ->
      ls.usernote.showForm()
    $('#follow_user').on 'click', ->
      ls.user.followToggle(this, this.dataset.user_id)
  else if window.location.pathname.match "stream"
    $('#stream_get_more_all').on 'click', ->
      ls.stream.getMoreAll()
    $('#stream_get_more').on 'click', ->
      ls.stream.getMore()
    $('#stream_get_more_by_user').on 'click', ->
      ls.stream.getMoreByUser(this.dataset.user_id)
    $('.streamEventTypeCheckbox').on 'click', ->
      ls.stream.switchEventType this.dataset.target_type
    $('#stream_users_complete').on 'keydown', (e) ->
      if e.which == 13
        ls.stream.appendUser()
    $('#stream_users_complete+div').on 'click', () ->
      ls.stream.appendUser()
    $(document).on 'click', '.streamUserCheckbox', () ->
      if this.checked
        ls.stream.subscribe this.dataset.user_id
      else
        ls.stream.unsubscribe this.dataset.user_id
  else if window.location.pathname.match "feed"
    $('#userfeed_users_complete').on 'keydown', (e) ->
      if e.which == 13
        ls.userfeed.appendUser()
    $('#userfeed_users_complete+div').on 'click', () ->
        ls.userfeed.appendUser()
    $(document).on 'click', '.userfeedUserCheckbox', () ->
      if this.checked
        ls.userfeed.subscribe 'users', this.dataset.user_id
      else
        ls.userfeed.unsubscribe 'users', this.dataset.user_id
  else if window.location.pathname.match("blog/add") || window.location.pathname.match("blog/edit")
    $(document).ready () ->
      ls.blog.loadInfoType document.getElementById('blog_type').value
    $('#blog_type').on 'change', () ->
      ls.blog.loadInfoType this.value
  else if window.location.pathname.match "talk/add"
    $('#fake_talk_add, #talk_preview').on 'click', (e) ->
      e.preventDefault()
      document.getElementById('talk_title').value = contentRemoveBadChars document.getElementById('talk_title').value
      document.getElementById('talk_text').value = contentMediaParser contentRemoveBadChars document.getElementById('talk_text').value
      if (this.id == 'talk_preview')
        document.getElementById('text_preview').parentNode.style.display = 'block'
        textPreview 'talk_text', false
      else
        document.getElementById('submit_talk_add').click()
  else if window.location.pathname.match("edit") || window.location.pathname.match("add")
    $(document).ready () ->
      ls.blog.loadInfo document.getElementById("blog_id").value
    $('#blog_id').on 'change', () ->
      ls.blog.loadInfo this.value
    $('.js-tags-help-link').on 'click', () ->
      str = if this.dataset.insert? then this.dataset.insert else this.textContent
      targetForm = document.getElementsByTagName("textarea")[0]
      caret = targetForm.selectionStart
      if isNaN caret
        targetForm.value += str
      else
        targetForm.value = targetForm.value.substring(0,caret) + str + targetForm.value.substring(caret)
    $('#tags-help-toggle').on 'click', ->
      $('#tags-help').toggle()
    $(document).on 'click', '#question_list .icon-synio-remove', () ->
      ls.poll.removeAnswer this
    $('#question_list+a').on 'click', () ->
      ls.poll.addAnswer()
    $('#fake_save, #fake_publish, .submit-preview'). on 'click', (e) ->
      e.preventDefault()
      document.getElementById('topic_title').value = contentRemoveBadChars document.getElementById('topic_title').value
      document.getElementById('topic_tags').value = contentRemoveBadChars document.getElementById('topic_tags').value
      document.getElementById('topic_text').value = contentRemoveBadChars contentMediaParser document.getElementById('topic_text').value
      if this.dataset.target
        document.getElementById(this.dataset.target).click()
      else
        ls.topic.preview 'form-topic-add', 'text_preview'
module.exports = init
