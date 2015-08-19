$ = require "jquery"
{forEach, map, reduce} = require "lodash"

{ajax, ajaxSubmit} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"

router = window.aRouter


favTypes =
  topic:
    url: "${router.ajax}favourite/topic/"
    targetName: 'idTopic'
  talk:
    url: "${router.ajax}favourite/talk/"
    targetName: 'idTalk'
  comment:
    url: "${router.ajax}favourite/comment/"
    targetName: 'idComment'


toggle = (idTarget, objFavourite, type) ->
  unless favTypes[type]
    return false
  objFavourite = $ objFavourite
  params = {}
  params['type'] = !@objFavourite.hasClass("active")
  params[favTypes[type].targetName] = idTarget
  ajax favTypes[type].url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
      return

    notice null, result.sMsg
    objFavourite.removeClass "active"
    if result.bState
      objFavourite.addClass "active"
      showTags type, idTarget
    else
      hideTags type, idTarget
    favCount = $ "#fav_count_#{type}_#{idTarget}"
    favCount.text result.iCount
    if result.iCount > 0 then favCount.show() else favCount.hide()
  false

showEditTags = (idTarget, type, obj) ->
  form = $ "#favourite-form-tags"
  $('#favourite-form-tags-target-type').val type
  $('#favourite-form-tags-target-id').val idTarget
  text = ''
  tags = $('.js-favourite-tags-' + $('#favourite-form-tags-target-type').val() + '-' + $('#favourite-form-tags-target-id').val())

  text = reduce(
    map(tags.find('.js-favourite-tag-user a'), (tag) -> tag.text),
    (a, b) -> "#{a}, #{b}"
  )

  $('#favourite-form-tags-tags').val text
  form.jqmShow()
  false


hideEditTags = ->
  $('#favourite-form-tags').jqmHide()
  false

saveTags = (form) ->
  url = "${router.ajax}favourite/save-tags/"
  ajaxSubmit url, $(form), (result) ->
    if result.bStateError
      error null, result.sMsg
      return

    hideEditTags()
    type = $('#favourite-form-tags-target-type').val()
    iTargetId = $('#favourite-form-tags-target-id').val()
    tags = $ ".js-favourite-tags-#{type}-#{iTargetId}"
    tags.find('.js-favourite-tag-user').detach()
    edit = tags.find('.js-favourite-tag-edit')
    forEach result.aTags, (value) ->
      edit.before """<li class="#{type}-tags-user js-favourite-tag-user">, <a rel="tag" href="#{value.url}">#{value.tag}</a></li>"""
  false

hideTags = (targetType, targetId) ->
  tags = $ ".js-favourite-tags-#{targetType}-#{targetId}"
  tags.find('.js-favourite-tag-user').detach()
  tags.find('.js-favourite-tag-edit').hide()
  hideEditTags()

showTags = (targetType, targetId) ->
  $(".js-favourite-tags-#{targetType}-#{targetId}").find('.js-favourite-tag-edit').show()


module.exports = {toggle, showEditTags, saveTags}