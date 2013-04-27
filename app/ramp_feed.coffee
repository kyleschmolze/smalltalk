module.exports = (socket) ->
  canned_data = false
  refresh_interval = 2
  timestamp = null
  if canned_data
    timestamp = 1367092379329
  
  setInterval ->
    request = require('request')
    url = 'http://livefeed.api.tv/hack2013/v1/getlivefeeditems/args/livefeed/1632384/showMatches/true/'
    if timestamp
      timestamp += 1
      url += "starttime/" + timestamp + "/duration/200/format.json"
    else 
      url += "starttime/last/duration/300/format.json"
    request url, (error, response, body) ->
      console.log url
      if canned_data
        timestamp += refresh_interval

      if (error || response.statusCode != 200)
        console.log error
        console.log response.statusCode
      else
        results = JSON.parse(body)
        console.log results["LiveFeedItems"].length
        for result in results["LiveFeedItems"]
          console.log result["Data"]["Text"]
          #socket.emit 'ping', {msg: JSON.stringify(result)}

          t = result["Timestamp"]
          console.log t
          if !canned_data && (timestamp || t > timestamp)
            timestamp = t
          for match in result["Matches"]
            #console.log JSON.stringify match
            for action in match["Actions"]
              for attribute in action["Attributes"]
                console.log attribute["Value"]
              if action["Type"].indexOf("espn") != -1
                socket.emit 'new-item', {msg: JSON.stringify(result["Matches"])}

  , refresh_interval * 1000