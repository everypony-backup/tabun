_registry = {}

module.exports =
  get: (sName) ->
    _registry[sName]

  set: (sName, data) ->
    _registry[sName] = data

