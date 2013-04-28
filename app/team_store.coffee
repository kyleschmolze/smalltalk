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
            head = this.NextHeadline()
            #console.log "Success! #{head.title}"
            opts.success head
          else
            opts.failure()
        failure: =>
          opts.failure()

  NextHeadline: ->
    this.localData.index = (this.localData.index + 1) % this.localData.headlines.length
    this.localData.headlines[this.localData.index]
