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
            socket.emit 'new-item',
              title: JSON.stringify(result["Matches"])
              image: 'http://www.nba.com/media/allstar2008/rallen_300_080130.jpg'
              description: "One of the most accurate 3-point and free throw shooters in NBA history,[1][2] he is a ten-time NBA All-Star, and won an NBA championship in 2008, as well as an Olympic gold medal as a member of the 2000 United States men's basketball team. Allen has acted in two films, including a lead role in the 1998 Spike Lee film He Got Game. Allen is the NBA all-time leader both in three-point field goals made and attempted."
  , 2000
