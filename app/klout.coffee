request = require('request')
apiKey = 'ycae8ufs2rzp3mfrpfeserzf'

module.exports = -> api

api =

  GetScore: (playerData, callback) ->
    if this.dictionary[playerData.metadata.name]?
      url = "http://api.klout.com/v2/identity.json/twitter?screenName=#{this.dictionary[playerData.metadata.name]}&key=#{apiKey}"
      request url, (error, response, body) ->
        if (!error and response.statusCode is 200)
          results = JSON.parse(body)
          if results.id
            url2 = "http://api.klout.com/v2/user.json/#{results.id}/score?key=#{apiKey}"
            request url2, (error2, response2, body2) ->
              results2 = JSON.parse(body2)
              callback(results2.score)
          else
            callback(0)
        else
          callback(0)
    else
      callback(0)
  
  dictionary:
    "Jason Terry": "jasonterry31"
    "Kevin Durant": "KDTrey5"

