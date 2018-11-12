$ = require "jquery"
{forEach, map, reduce} = require "lodash"

{ajax, ajaxSubmit} = require "core/ajax.coffee"
{gettext} = require "core/lang.coffee"
{error, notice} = require "core/messages.coffee"
routes = require("lib/routes").default


favTargets =
  comment: 'idComment'
  topic: 'idTopic'
  talk: 'idTalk'
  user: 'idUser'


toggle = (idTarget, objFavourite, type) ->
  unless favTargets[type]
    return false
  objFavourite = $ objFavourite
  params = {}
  params.type = not objFavourite.hasClass "active"
  params[favTargets[type]] = idTarget
  ajax routes.favourite[type], params, (result) ->
    if result.bStateError
      return error null, result.sMsg

    notice null, result.sMsg
    objFavourite.toggleClass "active", result.bState

    if result.bState
      objFavourite.text gettext "favourite_in"
      showTags type, idTarget
    else
      objFavourite.text gettext "favourite_add"
      hideTags type, idTarget

    favCount = $ "#fav_count_#{type}_#{idTarget}"
    favCount.text result.iCount || ''
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
  url = routes.favourite.saveTags
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
      edit.before """<span class="#{type}-tags-user js-favourite-tag-user">, <a rel="tag" href="#{value.url}">#{value.tag}</a></span>"""
  false

hideTags = (targetType, targetId) ->
  tags = $ ".js-favourite-tags-#{targetType}-#{targetId}"
  tags.find('.js-favourite-tag-user').detach()
  tags.find('.js-favourite-tag-edit').hide()
  hideEditTags()

showTags = (targetType, targetId) ->
  $(".js-favourite-tags-#{targetType}-#{targetId}").find('.js-favourite-tag-edit').show()


module.exports = {toggle, showEditTags, saveTags}
