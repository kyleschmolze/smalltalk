module.exports = (socket) ->
  opts =
    canned_data: false
    refresh_interval: 2
    timestamp: null
    results: null

  if opts.canned_data
    opts.timestamp = 1367092379329
  
  setInterval ->
    request = require('request')
    url = 'http://livefeed.api.tv/hack2013/v1/getlivefeeditems/args/livefeed/1632384/showMatches/true/'
    if opts.timestamp
      opts.timestamp += 1
      url += "starttime/" + opts.timestamp + "/duration/200/format.json"
    else
      url += "starttime/last/duration/300/format.json"
    request url, (error, response, body) ->
      console.log url
      if opts.canned_data
        opts.timestamp += opts.refresh_interval

      if (error || response.statusCode != 200)
        console.log error
        console.log response.statusCode
      else
        opts.results = JSON.parse(body)
        console.log opts.results["LiveFeedItems"].length
        if (item = extractPlayerItem(opts))? and false
          socket.emit 'new-item', item
        else if (item = extractRuleItem(opts))?
          socket.emit 'new-item', item

  , opts.refresh_interval * 1000



  extractPlayerItem = (opts) ->
    for result in opts.results["LiveFeedItems"]
      console.log result["Data"]["Text"]
      #socket.emit 'ping', {msg: JSON.stringify(result)}

      t = result["Timestamp"]
      console.log t
      if !opts.canned_data && (opts.timestamp || t > opts.timestamp)
        opts.timestamp = t
      for match in result["Matches"]
        #console.log JSON.stringify match
        for action in match["Actions"]
          for attribute in action["Attributes"]
            console.log attribute["Value"]
            #if action["Type"].indexOf("espn") != -1
            #socket.emit 'new-item', {msg: JSON.stringify(result["Matches"])}
            return {
              title: JSON.stringify(result["Matches"])
              image: 'http://www.nba.com/media/allstar2008/rallen_300_080130.jpg'
              description: "A description."
            }
    return null


  extractRuleItem = (opts) ->
    return {
      title: "Something new."
      image: 'http://www.nba.com/media/allstar2008/rallen_300_080130.jpg'
      description: "A description."
    }
    return null
