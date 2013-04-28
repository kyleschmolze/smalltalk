request = require('request')

module.exports = ->
	translator

translator =

	GetEnglish: (text, opts) ->
		url = "https://www.googleapis.com/language/translate/v2?key=AIzaSyDHlXrqiki-MT16Znbbl3jvnc9-e7o5YXk&source=es&target=en"
		url += "&q=#{text}"
		words = text.split(" ")
		for t in words
			if t != ""
				url += "&q=#{t}"
		request url, (error, response, body) ->
			if (!error and response.statusCode is 200)
				results = JSON.parse(body)
				translation = results.data?.translations?[0].translatedText
				
				t = []
				for i in [1..results.data?.translations.length - 1] by 1
					t.push({original: words[i].replace(/[.?!]/,""), translated: results.data?.translations?[i].translatedText.replace(/[.?!]/,"")})

				opts.success { text: text, translatedText: translation, translations: t }
		return null

