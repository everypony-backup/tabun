$ = require 'jquery'


class Notifier
  options:
    core: 'notifier'
    box_class: 'n-box'
    notice_class: 'n-notice'
    error_class: 'n-error'
    close_class: 'n-close'
    duration: 4000

  notices: {}

  broadcast: (title, message, type) ->
    @core()
    id = 'notice-' + @timestamp()
    # set notices object
    @notices[id] =
      id: id
    notice =
      id: id
      ttl: title
      msg: message
    # box
    $('#' + @options.core).append @box(notice).addClass(type)

  notice: (title, message) ->
    @broadcast title, message, @options.notice_class

  error: (title, message) ->
    @broadcast title, message, @options.error_class

  core: ->
    core = @options.core
    if $('#' + core).length == 0 then $('body').append('<div id="' + core + '"></div>') else $('#' + core)

  box: (notice) ->
    box = $('<div id="' + notice.id + '" class="' + @options.box_class + '"></div>')
    if notice.ttl != null
      box.append $('<h3></h3>').append(notice.ttl)
    box.append $('<p></p>').append(notice.msg)
    box.hide().show()
    @life box, notice.id
    @events box, notice.id
    box

  events: (box, seed) ->
    $(box).bind 'click', (event) =>
      seed = $(event.currentTarget).attr('id')
      @destroy seed, true

    $(box).bind 'mouseover', (event) =>
      if @notices[$(event.currentTarget).attr('id')].interval
        seed = $(event.currentTarget).attr('id')
        @destroy seed

    $(box).bind 'mouseout', (event) =>
      @life event.currentTarget, $(event.currentTarget).attr('id')

  life: (box, seed) ->
    if !@notices[seed].duration
      @notices[seed].duration = @options.duration
    @notices[seed].interval = {}
    @notices[seed].interval = setInterval(
      => (@destroy seed, true),
      @notices[seed].duration
    )

  destroy: (seed, remove) ->
    clearInterval @notices[seed].interval
    delete @notices[seed].interval
    if remove == true
      $('#' + seed).slideUp 250, ->
        $(this).remove()

  timestamp: ->
    (new Date).getTime()

notifier = new Notifier()

module.exports = notifier
