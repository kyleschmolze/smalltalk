module.exports = () ->
  triviaStore


triviaStore =
  localDataStore: {}
  playerDetails: {}
  _shuffle: (a) ->
    i = a.length
    while --i > 0
      j = ~~(Math.random() * (i + 1)) # ~~ is a common optimization for Math.floor
      t = a[j]
      a[j] = a[i]
      a[i] = t
    a

  GrabRandomTriviaFromLocalStore: (playerId) ->
    for h in this.localDataStore[playerId]
      if !h.used?
        h.used = true
        return {
          type: "player",
          title: h["headline"],
          description: h["text"]
          image: this.playerDetails[playerId]['headshots']['xlarge']['href']
        }
    for h in this.localDataStore[playerId]
      h.used = null
      return this.GrabRandomTriviaFromLocalStore(playerId)

  GetPlayerNotes: (results, opts) ->
    playerId = this.ExtractPlayerItem(results)
    if !playerId
      opts.failure()
      return
    if !this.playerDetails[playerId]
      espn = require("./espn")()
      espn.GetAthleteDetails "basketball", "nba", playerId, (details) =>
          if details
            this.playerDetails[playerId] = details
            console.log "details success!!"
            console.log details
            opts.success {
                      type: "player",
                      title: details["fullName"],
                      description:"#{details['firstName']}, repping #{details['team']['name']}, weighs in at a massive #{details.weight} pounds.", 
                      image: details['headshots']['xlarge']['href']
                    }
          else
            console.log "details failure!!"
            this.GetPlayerTrivia(results, opts)
    else
      this.GetPlayerTrivia(results, opts)

  GetPlayerTrivia: (results, opts) ->
    playerId = this.ExtractPlayerItem(results)
    if !playerId
      opts.failure()
      return

    triviaArray = this.localDataStore[playerId]
    if !triviaArray
      # pull data from espn
      espn = require("./espn")()
      espn.GetAthleteTrivia playerId, (headlines)=>
        if headlines.length > 0
          console.log "notes success!!"
          this.localDataStore[playerId] = this._shuffle(headlines)
          opts.success this.GrabRandomTriviaFromLocalStore(playerId)
        else
          console.log "notes failure!!"
          opts.failure()

    else
      opts.success this.GrabRandomTriviaFromLocalStore(playerId)

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

    
