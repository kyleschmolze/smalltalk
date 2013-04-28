module.exports = (socket) ->
  #trivia_store = require("./trivia_store")()
  translator = require("./translator")()
  #team_store = require("./team_store")()

  opts =
    canned_data: false
    refresh_interval: 15000
    timestamp: null
    results: null
  
  makeRequest = ->
    sentences = ""
    request = require('request')
    url = 'http://livefeed.api.tv/hack2013/v1/getlivefeeditems/args/livefeed/1632383/showMatches/true/'
    if !opts.timestamp
      if opts.canned_data
        opts.timestamp = 1367022212000
        url += "starttime/" + opts.timestamp + "/duration/3000/format.json"
      else
        url += "starttime/last/duration/3000/format.json"
    else
      if opts.canned_data
        opts.timestamp += opts.refresh_interval
        url += "starttime/" + opts.timestamp + "/duration/#{opts.refresh_interval / 1000}/format.json"
      else
        opts.timestamp += 1
        url += "starttime/" + opts.timestamp + "/duration/200/format.json"
      
    request url, (error, response, body) ->
      
      if (error || response.statusCode != 200)
        console.log error
        console.log response.statusCode
      else
        opts.results = JSON.parse(body)

        for result in opts.results["LiveFeedItems"]
          t = result["Timestamp"]
          if !opts.canned_data && (opts.timestamp || t > opts.timestamp)
            opts.timestamp = t
          text = result["Data"]["Text"]
          sentences += (text.replace(/\n\n/, " "))
        temp = sentences.split(/[.?!]/)
        lastSentence = temp.pop()
        s = []
        for sentence in temp
          lastIndex = sentences.indexOf(sentence) + sentence.length
          s.push(sentence + sentences.substr(lastIndex, 1))
        sentences = lastSentence
        for sentence in s
          sentence = sentence.replace(/[><]../, "")
          translator.GetEnglish sentence,
            success: (english) ->
              socket.emit 'new-item', english
            failure: ->
              console.log "O noes"


  makeRequest()
  setInterval makeRequest, opts.refresh_interval

