module.exports = () ->
  triviaStore


espn = require("./espn")()
klout = require("./klout")()

triviaStore =
  allPlayerData: {} # { playerId: { items: [], league: 'nba', sport: 'basketball' }

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
    else if !this.allPlayerData[playerId]?
      this.BuildPlayerData playerId, (newPlayerData) =>
        this.allPlayerData[newPlayerData.id] = newPlayerData
        if this.allPlayerData[playerId]
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

          klout.GetScore playerData, (score) =>
            playerData.metadata.score = score

            #All done grabbin teh data!
            if playerData.items.length > 0
              playerData.items = this._shuffle(playerData.items)

            callback(playerData)

  PullItem: (playerId) ->
    this.index or= 0
    thisPlayer = this.allPlayerData[playerId]
    item = thisPlayer.items[this.index]
    this.index = this.index + 1 % thisPlayer.items.length

    item.metadata = thisPlayer.metadata
    item.name = thisPlayer.name
    item.image = thisPlayer.image
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
