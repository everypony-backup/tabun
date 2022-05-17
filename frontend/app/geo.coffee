$ = require "jquery"
{forEach} = require "lodash"

{ajax} = require "core/ajax.coffee"
lang = require "core/lang.coffee"
{error, notice} = require "core/messages.coffee"
routes = require("lib/routes").default


loadRegions = ($country) ->
  $region = $country.parents('.js-geo-select').find('.js-geo-region')
  $city = $country.parents('.js-geo-select').find('.js-geo-city')
  $region.empty()
  $region.append """<option value="">#{lang.get 'geo_select_region'}</option>"""
  $city.empty()
  $city.hide()

  unless $country.val()
    $region.hide()
    return

  url = routes.geo.regions
  params = country: $country.val()

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      forEach result.aRegions, (value) ->
        $region.append """<option value="#{value.id}">#{value.name}</option>"""
      $region.show()


loadCities = ($region) ->
  $city = $region.parents('.js-geo-select').find('.js-geo-city')
  $city.empty()
  $city.append """<option value="">#{lang.get 'geo_select_city'}</option>"""

  unless $region.val()
    $city.hide()
    return

  url = routes.geo.cities
  params = region: $region.val()

  ajax url, params, (result) ->
    if result.bStateError
      error null, result.sMsg
    else
      forEach result.aCities, (value) ->
        $city.append """<option value="#{value.id}">#{value.name}</option>"""
      $city.show()


initSelect = ->
  forEach $('.js-geo-select'), (node) ->
    $(node).find('.js-geo-country').on 'change', (e) ->
      loadRegions $(e.target)

    $(node).find('.js-geo-region').on 'change', (e) ->
      loadCities $(e.target)


module.exports = {initSelect}
