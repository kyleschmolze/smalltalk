module.exports = (socket) ->
  trivia_store = require("./trivia_store")()
  dictionary_store = require("./dictionary_store")()
  team_store = require("./team_store")()

  opts =
    canned_data: true
    refresh_interval: 2000
    timestamp: null
    results: null
    teams: [6]
  
  setInterval ->
    request = require('request')
    url = 'http://livefeed.api.tv/hack2013/v1/getlivefeeditems/args/livefeed/1632384/showMatches/true/'
    if !opts.timestamp
      if opts.canned_data
        opts.timestamp = 1367022212000
        url += "starttime/" + opts.timestamp + "/duration/3000/format.json"
      else
        url += "starttime/last/duration/3000/format.json"
    else
      if opts.canned_data
        opts.timestamp += opts.refresh_interval
        url += "starttime/" + opts.timestamp + "/duration/2/format.json"
      else
        opts.timestamp += 1
        url += "starttime/" + opts.timestamp + "/duration/200/format.json"
      
    request url, (error, response, body) ->
      
      if (error || response.statusCode != 200)
        console.log error
        console.log response.statusCode
      else
        opts.results = JSON.parse(body)

        for result in opts.results
          t = result["Timestamp"]
          console.log t
          if !opts.canned_data && (opts.timestamp || t > opts.timestamp)
            opts.timestamp = t
        trivia_store.GetPlayerNotes opts.results,
          success: (headline) ->
            socket.emit 'new-item', headline
          failure: ->
            dictionary_store.GetDefinition opts.results,
              success: (rule) ->
                socket.emit 'new-item', rule
              failure: ->
                team_store.GetHeadline opts.teams,
                  success: (headline) ->
                    socket.emit 'new-item', headline
                  failure: ->
                    null
  , opts.refresh_interval
