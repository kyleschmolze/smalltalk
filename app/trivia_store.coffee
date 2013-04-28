module.exports = () ->
  triviaStore


espn = require("./espn")()

triviaStore =
  playerData: {} # { playerId: { items: [], league: 'nba', sport: 'basketball' }

  _shuffle: (a) ->
    i = a.length
    while --i > 0
      j = ~~(Math.random() * (i + 1)) # ~~ is a common optimization for Math.floor
      t = a[j]
      a[j] = a[i]
      a[i] = t
    a

  GetPlayerNotes: (results, opts) ->
    playerId = this.ExtractPlayerItem(results)
    if !playerId?
      opts.failure()
    else if !this.playerData[playerId]?
      this.BuildPlayerData playerId, =>
        if this.playerData[playerId]
          opts.success this.PullItem playerId
        else
          opts.failure()
    else
      opts.success this.PullItem playerId

  BuildPlayerData: (playerId, callback) ->
    playerData =
      id: playerId
      sport: 'basketball'
      league: 'nba'
      items: []

    espn.GetAthleteDetails playerData, (funfacts) =>
      playerData.items = playerData.items.concat funfacts

      #Got our details, let's add some trivia!!
      espn.GetAthleteTrivia playerData, (triviafacts) =>
        playerData.items = playerData.items.concat triviafacts

        #Got our trivia, let's add some headlines!
        espn.GetAthleteHeadlines playerData, (headlines) =>
          playerData.items = playerData.items.concat headlines

          #All done grabbin teh data!
          if playerData.items.length > 0
            playerData.items = this._shuffle(playerData.items)
            this.playerData[playerId] = playerData
          callback()

  PullItem: (playerId) ->
    this.index or= 0
    item = this.playerData[playerId].items[this.index]
    this.index = this.index + 1 % this.playerData[playerId].items.length

    item.name = this.playerData.name
    item.image = this.playerData.image
    item

  ExtractPlayerItem: (results) ->
    for result in results["LiveFeedItems"]
      console.log result["Data"]["Text"].replace(/\n/g, '')

      for match in result["Matches"]
        #console.log JSON.stringify match
        for action in match["Actions"]
          if action["Type"].indexOf("espn") != -1
            for attribute in action["Attributes"]
              if attribute["Name"] == "Id"
                return attribute["Value"]
    return null
