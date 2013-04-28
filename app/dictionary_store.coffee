module.exports = ->
  dictionary_store

dictionary = require("./dictionaries/basketball")

dictionary_store =
  GetDefinition: (results, opts) ->
    text = []
    for result in results["LiveFeedItems"]
      text.push result["Data"]["Text"]
    text = text.reverse().join(' ').toLowerCase().replace(/\s\s/g, " ")

    for term, definition of dictionary
      if text.indexOf(term) != -1
        opts.success
          category: "definition"
          title: term
          description: dictionary[term]
        return null
    opts.failure()
