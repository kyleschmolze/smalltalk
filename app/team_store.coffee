module.exports = ->
  team_store

espn = require("./espn")()
team_store =
  localData:
    index: 0

  GetHeadline: (teams, opts) ->
    if this.localData.headlines?
      return this.NextHeadline()
    else
      espn.GetTeamHeadlines
        teams: teams
        success: (headlines) =>
          if headlines?
            this.localData.headlines = headlines
            opts.success this.NextHeadline()
          else
            opts.failure()
        failure: =>
          opts.failure()

  NextHeadline: ->
    console.log "SOMETHING"
    console.log this.localData.headlines
    this.localData.headlines[this.localData.index]
    this.localData.index = (this.localData.index + 1) % this.localData.headlines.length
