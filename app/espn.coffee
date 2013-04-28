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


  GetAthleteTrivia: (playerData, callback) ->
    url = "http://api.espn.com/v1/sports/news/notes/?athletes=#{playerData.id}&apikey=#{apiKey}"
    request url, (error, response, body) ->
      if (!error and response.statusCode is 200)
        results = JSON.parse(body)
        headlines = []
        for note in results.notes
          if (note.text.length < 400)
            headlines.push
              title: note.headline
              description: note.text
              category: 'player-trivia'

        callback(headlines)
      else
        callback([])

  GetAthleteHeadlines: (playerData, callback) ->
    url = "http://api.espn.com/v1/sports/#{playerData.sport}/#{playerData.league}/news/?athletes=#{playerData.id}&apikey=#{apiKey}"
    request url, (error, response, body) ->
      if (!error and response.statusCode is 200)
        results = JSON.parse(body)
        headlines = []
        for headline in results.headlines
          headlines.push
            category: 'player-headline'
            title: headline.headline
            description: headline.description

        callback headlines
      else
        callback []

  GetAthleteDetails: (playerData, callback) ->
    url = "http://api.espn.com/v1/sports/#{playerData.sport}/#{playerData.league}/athletes/#{playerData.id}?apikey=#{apiKey}"
    request url, (error, response, body) ->
      if (!error and response.statusCode is 200)
        results = JSON.parse(body)
        details = results.sports?[0].leagues?[0].athletes?[0]
        funfacts = []
        if details?
          #set playerData for everyone else!
          name = details['displayName']
          playerData.name = name
          playerData.image = details['headshots']['medium']['href']

          funfacts.push "#{name} weighs #{details['weight']} lbs."
          funfacts.push "#{name} is #{details['age']} years old."
          funfacts.push "#{name} is #{details['height']} inches tall."
          exp = details['experience'] || 0
          if exp > 1
            funfacts.push "#{name} has been playing for #{exp} years."
          else if exp == 1
            funfacts.push "This is #{name}'s first year."
          
        funitems = []
        for funfact in funfacts
          funitems.push
            title: funfact
            category: 'player-fact'

        callback funitems
      else
        callback []
    return null

  GetTeamHeadlines: (opts) ->
    opts.sport = 'basketball'
    opts.league = 'mens-college-basketball'

    url = "http://api.espn.com/v1/sports/#{opts.sport}/#{opts.league}/news/headlines/?teams=#{opts.teams.join(',')}&_accept=application%2Fjson&apikey=#{apiKey}"
    request url, (error, response, body) ->
      if (!error and response.statusCode is 200)
        results = JSON.parse(body)
        headlines = []
        if results.headlines?
          for headline in results.headlines
            headlines.push
              title: "Team news: #{headline.headline}"
              description: headline.description
              body: headline.story
              image: headline.images?[0]?.url
              url: headline.links?.mobile?.href
              category: 'team'

          return opts.success headlines
        else
          return opts.failure()
      else
        return opts.failure()
