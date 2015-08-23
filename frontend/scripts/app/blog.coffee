$ = require "jquery"
{forEach, throttle} = require "lodash"

lang = require "core/lang.coffee"
{ajax, ajaxSubmit} = require "core/ajax.coffee"
{error, notice} = require "core/messages.coffee"

router = window.aRouter


toggleJoin = (obj, idBlog) ->
  url = "#{router.blog}ajaxblogjoin/"
  params = idBlog: idBlog

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
      return
    notice null, result.sMsg
    obj = $(obj)
    text = if result.bState then lang.get('blog_leave') else lang.get('blog_join')
    obj.empty().text text
    obj.toggleClass 'active'
    $("#blog_user_count_#{idBlog}").text result.iCountUser
    unless obj.data "onlyText"
      label = if result.bState then lang.get 'blog_leave' else lang.get 'blog_join'
      obj.html """<i class="icon-synio-join"></i><span>#{label}</span>"""
      obj.toggleClass 'active', result.bState


addInvite = (idBlog) ->
  sUsers = $('#blog_admin_user_add').val()
  unless sUsers
    return false
  $('#blog_admin_user_add').val ''
  url = "#{router.blog}ajaxaddbloginvite/"
  params =
    users: sUsers
    idBlog: idBlog

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
      return
    forEach result.aUsers, (item) ->
      if item.bStateError
        error null, item.sMsg
      else
        if $('#invited_list').length == 0
          $('#invited_list_block').append $('<ul class="list" id="invited_list"></ul>')
        $('#invited_list').append $("""<li><a href="#{item.sUserWebPath}" class="user">#{item.sUserLogin}</a></li>""")
        $('#blog-invite-empty').hide()
  false


repeatInvite = (idUser, idBlog) ->
  url = "#{router.blog}ajaxrebloginvite/"
  params =
    idUser: idUser
    idBlog: idBlog

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      notice null, result.sMsg
  false


removeInvite = (idUser, idBlog) ->
  url = "#{router.blog}ajaxremovebloginvite/"
  params =
    idUser: idUser
    idBlog: idBlog

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
      return
    notice null, result.sMsg
    $("#blog-invite-remove-item-#{idBlog}-#{idUser}").remove()
    if $('#invited_list li').length == 0 then $('#blog-invite-empty').show()
  false


loadInfo = (idBlog) ->
  url = "#{router.blog}ajaxbloginfo/"
  params = idBlog: idBlog

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
      return
    $('#block_blog_info').html result.sText


loadInfoType = (type) ->
  $('#blog_type_note').text lang.get("blog_create_type_#{type}_notice")

searchBlogs = (formId) ->
  url = "#{router.blogs}ajax-search/"
  form = $ "##{formId}"

  inputSearch = form.find('input')
  inputSearch.addClass 'loader'

  ajaxSubmit url, form, (result) ->
    inputSearch.removeClass 'loader'
    $('#blogs-list-original').toogle(result.bStateError)
    $('#blogs-list-search').html(result.sText or '').toggle(not result.bStateError)

searchBlogsThrottled = throttle searchBlogs, 500

toggleInfo = ->
  $('#blog-mini').slideToggle()
  $('#blog').slideToggle()


module.exports = {
  addInvite
  loadInfo
  loadInfoType
  removeInvite
  repeatInvite
  searchBlogsThrottled
  toggleInfo
  toggleJoin
}