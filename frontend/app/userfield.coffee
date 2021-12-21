$ = require "jquery"
{forEach, merge} = require "lodash"

{ajax} = require "core/ajax.coffee"
lang = require "core/lang.coffee"
{error, notice} = require "core/messages.coffee"
routes = require("lib/routes").default

url = routes.userfields

iCountMax = 4

showAddForm = ->
  $('#user_fields_form_name').val ''
  $('#user_fields_form_title').val ''
  $('#user_fields_form_id').val ''
  $('#user_fields_form_pattern').val ''
  $('#user_fields_form_type').val ''
  $('#user_fields_form_action').val 'add'
  $('#userfield_form').jqmShow()
  return

showEditForm = (id) ->
  $('#user_fields_form_action').val 'update'
  name = $("#field_#{id} .userfield_admin_name").text()
  title = $("#field_#{id} .userfield_admin_title").text()
  pattern = $("#field_#{id} .userfield_admin_pattern").text()
  type = $("#field_#{id} .userfield_admin_type").text()
  $('#user_fields_form_name').val name
  $('#user_fields_form_title').val title
  $('#user_fields_form_pattern').val pattern
  $('#user_fields_form_type').val type
  $('#user_fields_form_id').val id
  $('#userfield_form').jqmShow()
  return
  

applyForm = ->
  $('#userfield_form').jqmHide()
  if $('#user_fields_form_action').val() == 'add'
    addUserfield()
  else if $('#user_fields_form_action').val() == 'update'
    updateUserfield()

addUserfield = ->
  name = $('#user_fields_form_name').val()
  title = $('#user_fields_form_title').val()
  pattern = $('#user_fields_form_pattern').val()
  type = $('#user_fields_form_type').val()
  params = merge {action: 'add'}, {name, title, pattern, type}

  ajax url, params, (data) ->
    if data.bStateError
      return error data.sMsgTitle, data.sMsg
    notice data.sMsgTitle, data.sMsg
    
    liElement = $('<li id="field_' + data.id + '"><span class="userfield_admin_name"></span > / <span class="userfield_admin_title"></span> / <span class="userfield_admin_pattern"></span> / <span class="userfield_admin_type"></span>' + '<div class="userfield-actions"><a class="icon-edit" href="javascript:ls.userfield.showEditForm(' + data.id + ')"></a> ' + '<a class="icon-remove" href="javascript:ls.userfield.deleteUserfield(' + data.id + ')"></a></div>')
    $('#user_field_list').append liElement
    $("#field_#{data.id} .userfield_admin_name").text name
    $("#field_#{data.id} .userfield_admin_title").text title
    $("#field_#{data.id} .userfield_admin_pattern").text pattern
    $("#field_#{data.id} .userfield_admin_type").text type
    return
  return


updateUserfield = ->
  id = $('#user_fields_form_id').val()
  name = $('#user_fields_form_name').val()
  title = $('#user_fields_form_title').val()
  pattern = $('#user_fields_form_pattern').val()
  type = $('#user_fields_form_type').val()
  params = merge {'action': 'update'}, {id, name, title, pattern, type}

  ajax url, params, (data) ->
    if data.bStateError
      return error data.sMsgTitle, data.sMsg

    notice data.sMsgTitle, data.sMsg
    $("#field_#{id} .userfield_admin_name").text name
    $("#field_#{id} .userfield_admin_title").text title
    $("#field_#{id} .userfield_admin_pattern").text pattern
    $("#field_#{id} .userfield_admin_type").text type
    return
  return


deleteUserfield = (id) ->
  unless confirm(lang.get('user_field_delete_confirm'))
    return
  params =
    'action': 'delete'
    'id': id
  
  ajax url, params, (data) ->
    if data.bStateError
      return error data.sMsgTitle, data.sMsg

    notice data.sMsgTitle, data.sMsg
    $('#field_' + id).remove()
    return
  return


addFormField = ->
  tpl = $('#profile_user_field_template').clone()

  value = undefined
  forEach tpl.find('select').find('option'), (node) ->
    val = $(node).val()
    if getCountFormField(val) < iCountMax
      value = val

  if value
    tpl.find('select').val value
    $('#user-field-contact-contener').append tpl.show()
  else
    error '', lang.get('settings_profile_field_error_max', count: iCountMax)
  false

changeFormField = (obj) ->
  iCount = getCountFormField($(obj).val())
  if iCount > iCountMax
    error '', lang.get('settings_profile_field_error_max', count: iCountMax)

getCountFormField = (value) ->
  iCount = 0
  forEach $('#user-field-contact-contener').find('select'), (v) ->
    if value == $(v).val()
      iCount++
  iCount

removeFormField = (obj) ->
  $(obj).parent('.js-user-field-item').detach()
  false

module.exports = {
  showAddForm
  showEditForm
  applyForm
  addUserfield
  updateUserfield
  deleteUserfield
  addFormField
  changeFormField
  getCountFormField
  removeFormField
}
