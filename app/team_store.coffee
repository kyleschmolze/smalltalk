module.exports = ->
  team_store

espn = require('espn')()
team_store =
  GetHeadline: (teams, opts) ->
    if this.headlines?
      return this.NextHeadline()
    else
      espn.GetTeamHeadlines
        success: (headlines) ->
          this.headlines = headlines
          opts.success this.NextHeadline()
        failure: ->
          opts.failure()

  NextHeadline: ->
    this.index or= 0
    this.headlines[this.index]
    this.index = (this.index + 1) % this.headlines.length
