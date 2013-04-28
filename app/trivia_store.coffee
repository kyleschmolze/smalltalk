module.exports = () ->
  triviaStore


triviaStore =
  localDataStore: {}
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
          title: h["headline"],
          description: h["text"]
        }
    for h in this.localDataStore[playerId]
      h.used = null
      return this.GrabRandomTriviaFromLocalStore(playerId)

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

    
