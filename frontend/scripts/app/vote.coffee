$ = require "jquery"
classNames = require "classnames"
{capitalize, has, isFunction} = require "lodash"

{ajax} = require "core/ajax.coffee"
lang = require "core/lang.coffee"
{error, notice} = require "core/messages.coffee"

router = window.aRouter

prefix =
  area: 'vote_area_'
  total: 'vote_total_'
  count: 'vote_count_'

voteTypes = 
  comment:
    url: "#{router.ajax}vote/comment/"
    targetName: 'idComment'
  topic:
    url: "#{router.ajax}vote/topic/"
    targetName: 'idTopic'
  blog:
    url: "#{router.ajax}vote/blog/"
    targetName: 'idBlog'
  user:
    url: "#{router.ajax}vote/user/"
    targetName: 'idUser'

vote = (idTarget, objVote, value, type) ->
  unless voteTypes[type]
    return false

  objVote = $(objVote)
  params = {}
  params['value'] = value
  params[voteTypes[type].targetName] = idTarget

  ajax voteTypes[type].url, params, (result) ->
    onVote idTarget, objVote, value, type, result


onVote = (idTarget, objVote, value, type, result) ->
  if result.bStateError
    error null, result.sMsg
    return
  notice null, result.sMsg

  iRating = parseFloat result.iRating

  divVoting = $ "##{prefix.area}#{type}_#{idTarget}"
  divTotal = $ "##{prefix.total}#{type}_#{idTarget}"
  divCount = $ "##{prefix.count}#{type}_#{idTarget}"

  divVoting.removeClass classNames "vote-count-positive", "vote-count-negative", "vote-count-zero", "not-voted"
  divVoting.addClass classNames "voted",
    "voted-up": value > 0
    "voted-down": value < 0
    "voted-zero": value == 0
    "vote-count-positive": iRating > 0
    "vote-count-negative": iRating < 0
    "vote-count-zero": iRating == 0

  if divCount.length > 0 and result.iCountVote then divCount.text parseInt(result.iCountVote)
  divTotal.text if iRating > 0 then "+#{iRating}" else if iRating < 0 then result.iRating else 0

  method = "onVote#{capitalize type}"
  if has(@, method) && isFunction @[method]
    @[method] idTarget, objVote, value, type, result

onVoteUser = (idTarget, objVote, value, type, result) ->
  $("#user_skill_#{idTarget}").text result.iSkill


module.exports = {vote}