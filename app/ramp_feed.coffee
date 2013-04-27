module.exports = (socket) ->
  timestamp = null
  setInterval ->
    request = require('request')
    url = 'http://livefeed.api.tv/hack2013/v1/getlivefeeditems/args/livefeed/1632384/showMatches/true/'
    if timestamp
      timestamp += 1
      url += "starttime/" + timestamp + "/format.json"
    else 
      url += "starttime/last/duration/300/format.json"
    request url, (error, response, body) ->
      if (!error && response.statusCode == 200)
        results = JSON.parse(body)
        for result in results["LiveFeedItems"]
          #socket.emit 'ping', {msg: JSON.stringify(result)}

          t = result["Timestamp"]
          if timestamp || t > timestamp
            timestamp = t
          console.log(result["Matches"])
          if result["Matches"].length
            socket.emit 'new-item', {msg: JSON.stringify(result["Matches"])}
  , 2000