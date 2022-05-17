###*
# Добавляет автокомплитер к полю ввода
###

$ = require "jquery"
{ajax} = require "./ajax.coffee"

split = (val) -> val.split /,\s*/
extractLast = (term) -> split(term).pop()

add = (obj, sPath, multiple) ->
  if multiple
    obj.bind('keydown', (event) ->
      if event.keyCode == 9 and $(@).data('autocomplete').menu.active
        event.preventDefault()
    ).autocomplete
      source: (request, response) ->
        ajax sPath, { value: extractLast(request.term) }, (data) ->
          response data.aItems

      search: ->
        term = extractLast(@value)
        if term.length < 2
          return false

      focus: -> false

      select: (event, ui) ->
        terms = split(@value)
        terms.pop()
        terms.push ui.item.value
        terms.push ''
        @value = terms.join(', ')
        false
  else
    obj.autocomplete source: (request, response) ->
      ajax sPath, { value: extractLast(request.term) }, (data) ->
        response data.aItems


module.exports = {add}
