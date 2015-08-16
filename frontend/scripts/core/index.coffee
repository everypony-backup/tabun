module.exports =
  msg: require "./messages.coffee" # TODO: internal
  autocomplete: require "./autocomplete.coffee" # TODO: internal

  tools: require "./tools.coffee"
  registry: require "./registry.coffee" # TODO: move to tools
  lang: require "./lang.coffee"
  timer: require "./timer.coffee"
