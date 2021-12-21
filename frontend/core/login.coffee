###*
# Компонента входа и регистрации
###

{assign} = require 'lodash'

React = require 'react'
Login = require("lib/react-login-component/login.jsx").default

{ajax} = require "core/ajax.coffee"
routes = require("lib/routes").default
{gettext} = require "core/lang.coffee"

# Helpers
prepareLoginLocale = (props) ->
  locale =
    'lang': document.documentElement.lang
  props.map (prop) ->
    locale[prop] = gettext prop
  locale

loginAjax = (login, password, remember, callback) ->
  params =
    'login': login
    'password': password
    'return-path': window.location.href
  if remember then params.remember = 'on'
  ajax routes.profile.login, params, (result) ->
    if result.bStateError
      callback 'err', result.sMsg
    else
      window.location = result.sUrlRedirect

reminderAjax = (email, callback) ->
  ajax routes.profile.reminder, {'mail': email}, (result) ->
    if result.bStateError
      callback 'err', result.sMsg
    else
      callback 'ok', result.sMsg

registrationAjax = (username, email, password, recaptcha, callback) ->
  params =
    'login': username
    'mail': email
    'password': password
    'password_confirm': password
    'g-recaptcha-response': recaptcha
    'return-path': window.location.href
  ajax routes.profile.registration, params, (result) ->
    if result.sUrlRedirect
      callback 'ok', "<strong>#{gettext('activation_title')}</strong><br />#{gettext('activation_description')}"
    else
      callback 'err', result.sMsg

validateAjax = (field, value, okMsg, callback) ->
  ajax routes.profile.validateFields, {'fields[0][field]': field, 'fields[0][value]': value}, (result) ->
    if result.aErrors
      callback 'err', result.aErrors[field][0]
    else
      callback 'ok', gettext 'entered_correctly'

validateUsername = (value, callback) ->
  if value.length == 0
    return callback 'err', gettext 'empty_username'
  else if value.length < 3
    return callback 'err', gettext 'username_too_short'
  else if value.lenght > 30
    return callback 'err', gettext 'username_too_long'
  else if not /^[a-zA-Z0-9-_]+$/.test value
    return callback 'err', gettext 'invalid_username'
  else
    return validateAjax 'login', value, gettext('username_available'), callback

validateEmail = (value, callback) ->
  re = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i
  if value.length == 0
    return callback 'err', gettext 'empty_email'
  else if not re.test value
    return callback 'err', gettext 'invalid_email'
  else
    return validateAjax 'mail', value, gettext('valid_email'), callback

onLogin = ({login, password, remember}, callback) =>
  loginAjax login, password, remember, callback

onRegister = ({username, email, password, recaptcha}, callback) =>
  registrationAjax username, email, password, recaptcha, callback

onRemind = ({email}, callback) =>
  reminderAjax email, callback

onValidate = (type, value, callback) =>
  switch type
    when 'username'
      validateUsername value, callback
    when 'email'
      validateEmail value, callback

      
# Initialization
module.exports = (props = {}) ->
    React.createElement(Login,
      assign
        isModal: true
        initiallyHidden: true
        hasNavigation: true
        isLabeled: false
        recaptcha: { key: RECAPTCHA_KEY }
        tabs: [
          { 'id': 'enter', 'url': '/login' }
          { 'id': 'registration', 'url': '/registration' }
          { 'id': 'reminder', 'url': '/login/reminder' }
        ]
        locale: prepareLoginLocale [ 'enter', 'registration', 'reminder', 'username_or_email', 'password', 'keep_me_logged_in',
          'sign_in', 'username', 'email', 'repeat_password', 'sign_up', 'your_email', 'remind_password', 'passwords_do_not_match',
          'empty_repeated_password', 'entered_correctly', 'password_too_short', 'password_too_simple', 'username_available',
          'username_not_available', 'empty_username', 'invalid_username', 'username_too_short', 'valid_email',
          'invalid_email', 'empty_email', 'trials_exceed_limit', 'validation_error_title', 'validation_error_description', 'empty_captcha']
        onLogin: onLogin
        onRegister: onRegister
        onRemind: onRemind

        onValidate: onValidate
      , props
    )
