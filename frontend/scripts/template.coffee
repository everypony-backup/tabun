$ = require "jquery"
require "jquery.jqmodal"


blocks = require "./blocks.coffee"
autocomplete = require "./core/autocomplete.coffee"

router = window.aRouter

init = ->
  # Popups
  $('#window_login_form').jqm()
  $('#blog_delete_form').jqm trigger: '#blog_delete_show', toTop: true
  $('#add_friend_form').jqm trigger: '#add_friend_show', toTop: true
  $('#window_upload_img').jqm()
  $('#favourite-form-tags').jqm()
  $('#modal_write').jqm trigger: '.js-write-window-show'
  $('#foto-resize').jqm modal: true, toTop: true
  $('#avatar-resize').jqm modal: true, toTop: true
  $('#userfield_form').jqm toTop: true

  # Autocomplete
  autocomplete.add $(".autocomplete-tags-sep"), "#{router.ajax}autocompleter/tag/", true
  autocomplete.add $(".autocomplete-tags"), "#{router.ajax}autocompleter/tag/", false
  autocomplete.add $(".autocomplete-users-sep"), "#{router.ajax}autocompleter/user/", true
  autocomplete.add $(".autocomplete-users"), "#{router.ajax}autocompleter/user/", false

  # Blocks
  blocks.init 'stream', group_items: true, group_min: 3
  blocks.init 'blogs'
  blocks.initSwitch 'tags'
  blocks.initSwitch 'upload-img'
  blocks.initSwitch 'favourite-topic-tags'
  blocks.initSwitch 'popup-login'


module.exports = init