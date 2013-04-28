request = require('request')
apiKey = 'n5u6v22j4525znf95x8qcssj'

module.exports = -> api

api =

  GetSchedule: () ->
    url = "http://api.espn.com/v1/sports/basketball/mens-college-basketball/events/?disable=links%2Cvenues%2Cstats%2Cathletes%2Clinescores&dates=20130428&apikey=#{apiKey}"
    request url, (error, response, body) ->
      if (!error and response.statusCode is 200)
        results = JSON.parse(body)
        console.log results.sports[0].leagues[0].events
    return null


  GetAthleteTrivia: (athleteId, callback) ->
    url = "http://api.espn.com/v1/sports/news/notes/?athletes=#{athleteId}&apikey=#{apiKey}"
    request url, (error, response, body) ->
      if (!error and response.statusCode is 200)
        results = JSON.parse(body)
        headlines = []
        for note in results.notes
          if (note.text.length < 400)
            headlines.push
              id: note.id
              headline: note.headline
              text: note.text

        return callback headlines
    return null

  GetAthleteHeadlines: (sport, league, athleteId, callback) ->
    url = "http://api.espn.com/v1/sports/#{sport}/#{league}/news/?athletes=#{athleteId}&apikey=#{apiKey}"
    #console.log url          
    request url, (error, response, body) ->
      if (!error and response.statusCode is 200)
        results = JSON.parse(body)
        headlines = []
        for headline in results.headlines
          headlines.push
            id: headline.id
            headline: headline.headline
            text: headline.description

        return callback headlines
    return null

  GetAthleteDetails: (sport, league, athleteId, callback) ->
    url = "http://api.espn.com/v1/sports/#{sport}/#{league}/athletes/#{athleteId}?apikey=#{apiKey}"
    request url, (error, response, body) ->
      if (!error and response.statusCode is 200)
        results = JSON.parse(body)
        details = results.sports?[0].leagues?[0].athletes?[0]
        return callback details
    return null

  GetTeamHeadlines: (opts) ->
    opts.sport = 'basketball'
    opts.league = 'mens-college-basketball'

    url = "http://api.espn.com/v1/sports/#{opts.sport}/#{opts.league}/news/headlines/?teams=#{opts.teams.join(',')}&_accept=application%2Fjson&apikey=#{apiKey}"
    request url, (error, response, body) ->
      if (!error and response.statusCode is 200)
        results = JSON.parse(body)
        headlines = results.headlines?[0].leagues?[0].athletes?[0]
        return opts.success headlines
      else
        return opts.failure()
