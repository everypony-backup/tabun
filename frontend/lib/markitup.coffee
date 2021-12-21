$ = require "jquery"
require "jquery.markitup"

commons = [
  {
    name: 'Жирный'
    className: 'edit-bold'
    key: 'B'
    openWith: '<strong>'
    closeWith: '</strong>'
  }
  {
    name: 'Курсив'
    className: 'edit-italic'
    key: 'I'
    openWith: '<em>'
    closeWith: '</em>'
  }
  {
    name: 'Зачеркнуть'
    className: 'edit-strike'
    key: 'S'
    openWith: '<s>'
    closeWith: '</s>'
  }
  {
    name: 'Подчеркнуть'
    className: 'edit-underline'
    key: 'U'
    openWith: '<u>'
    closeWith: '</u>'
  }
  {separator: '---------------'}
  {
    name: 'Верхний индекс'
    className: 'edit-superscript'
    openWith: '<sup>'
    closeWith: '</sup>'
  }
  {
    name: 'Нижний индекс'
    className: 'edit-subscript'
    openWith: '<sub>'
    closeWith: '</sub>'
  }
  {
    name: 'Уменьшить размер'
    className: 'edit-small'
    openWith: '<small>'
    closeWith: '</small>'
  }
  {separator: '---------------'}
]

headers = [
  {
    name: 'H4'
    className: 'edit-h4'
    openWith: '<h4>'
    closeWith: '</h4>'
  }
  {
    name: 'H5'
    className: 'edit-h5'
    openWith: '<h5>'
    closeWith: '</h5>'
  }
  {
    name: 'H6'
    className: 'edit-h6'
    openWith: '<h6>'
    closeWith: '</h6>'
  }
  {separator: '---------------'}
]

aligns = [
  {
    name: 'По левому краю'
    className: 'edit-alignment-left'
    openWith: '<span class="h-left">'
    closeWith: '</span>'
  }
  {
    name: 'По центру'
    className: 'edit-alignment-center'
    openWith: '<span class="h-center">'
    closeWith: '</span>'
  }
  {
    name: 'По правому краю'
    className: 'edit-alignment-right'
    openWith: '<span class="h-right">'
    closeWith: '</span>'
  }
  {separator: '---------------'}
]

quotesAndSpoilers = [
  {
    name: 'Цитировать'
    className: 'edit-quotation'
    key: 'Q'
    replaceWith: (m) -> "<blockquote>#{m.selectionOuter or m.selection or ''}</blockquote>"
  }
  {
    name: 'Код'
    className: 'edit-code'
    openWith: '<pre>'
    closeWith: '</pre>'
  }
  {
    name: 'Добавить спойлер'
    className: 'edit-spoiler'
    key: 'H'
    openWith: """<span class="spoiler"><span class="spoiler-title">[![Введите название спойлера: :!:Спойлер]!]</span><span class="spoiler-body">"""
    closeWith: '</span></span>'
    placeHolder: 'Текст спойлера'
  }
  {
    name: 'Lite-спойлер'
    className: 'edit-spoiler-gray'
    openWith: '<span class="spoiler-gray" onclick="">'
    closeWith: '</span>'
  }
  {separator: '---------------'}
]

lists = [
  {
    name: 'Обычный список'
    className: 'edit-list'
    openWith: '<li>'
    closeWith: '</li>'
    multiline: true
    openBlockWith: '<ul>\n'
    closeBlockWith: '\n</ul>'
  }
  {
    name: 'Нумерованный список'
    className: 'edit-list-order'
    openWith: '<li>'
    closeWith: '</li>'
    multiline: true
    openBlockWith: '<ol>\n'
    closeBlockWith: '\n</ol>'
  }
  {
    name: 'Элемент списка'
    className: 'edit-list-item'
    openWith: '<li>'
    closeWith: '</li>'
  }
  {separator: '---------------'}
]

embeds = [
  {
    name: 'Добавить изображение'
    className: 'edit-image'
    key: 'P'
    beforeInsert: -> $('#window_upload_img').jqmShow()
  }
  {
    name: 'Добавить видео'
    className: 'edit-video'
    replaceWith: """<video>[![Введите адрес видео::!:https://]!]</video>"""
  }
  {
    name: 'Добавить ссылку'
    className: 'edit-anchor'
    key: 'L'
    openWith: """<a href="[![Введите url адрес::!:http://]!]" (!(title="[![Title]!]")!)>"""
    closeWith: '</a>'
    placeHolder: 'Введите адрес ссылки…'
  }
  {separator: '---------------'}
]

misc = [
  {
    name: 'Разделитель'
    className: 'edit-hr'
    replaceWith: '<hr>'
  }
  {
    name: 'Новая строка'
    className: 'edit-br'
    replaceWith: '<br>'
  }
  {separator: '---------------'}
  {
    name: 'Пользователь'
    className: 'edit-user'
    replaceWith: """<ls user="[![Введите имя пользователя:]!]" />"""
  }
  {
    name: 'Очистка от тегов'
    className: 'edit-tag'
    replaceWith: (markitup) -> markitup.selection.replace /<(.*?)>/g, ''

  }
]

cut = [
  {
    name: 'Читать дальше →'
    className: 'edit-cut'
    replaceWith: """<cut name="[![Название:!:Читать дальше →]!]">"""
  }
]

topic =
  onShiftEnter:
    keepDefault: false
    replaceWith: '<br />\n'
  onCtrlEnter:
    keepDefault: false
    openWith: '\n<p>'
    closeWith: '</p>'
  onTab:
    keepDefault: false
    replaceWith: '    '
  markupSet: Array::concat(
    commons
    headers
    aligns
    quotesAndSpoilers
    lists
    embeds
    misc
    cut
  )

comment =
  onShiftEnter:
    keepDefault: false
    replaceWith: '<br />\n'
  onTab:
    keepDefault: false
    replaceWith: '    '
  markupSet: Array::concat(
    commons
    aligns
    quotesAndSpoilers
    embeds
    misc
  )

topics = -> $('.markitup-editor').markItUp topic

comments = -> $('.markitup-editor').markItUp comment

commentFor = (editbox) -> $(editbox).markItUp comment

module.exports = {topics, comments, commentFor}
