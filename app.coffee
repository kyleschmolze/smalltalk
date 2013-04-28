#!/usr/bin/env node
#/* Express 3 requires that you instantiate a `http.Server` to attach socket.io to first */

express = require 'express'
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
port = 8080
url  = 'http://localhost:' + port + '/'

espn = require('./app/espn')()

#/* We can access nodejitsu enviroment variables from process.env */
#/* Note: the SUBDOMAIN variable will always be defined for a nodejitsu app */
if(process.env.SUBDOMAIN)
  url = 'http://' + process.env.SUBDOMAIN + '.jit.su/'

server.listen(port)
console.log("Express server listening on port " + port)
console.log(url)

app.configure () ->
  app.use express.compress()
  app.use '/public', express.static(__dirname + '/public')
  #app.use express.favicon(__root + '/public/images/favicon.ico')
  #app.set '../views', __dirname + '/views'
  #app.set 'view engine', 'jade'
  #app.locals { layout: false, pretty: false }
  app.use express.logger()
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieSession { key: 'sesh', secret: 'superfuntime' }
  #app.use flash()
  app.use app.router

app.get '/', (req, res) ->
  res.sendfile(__dirname + '/index.html')

app.use(express.static(__dirname + '/public'))


#//Socket.io emits this event when a connection is made.
io.sockets.on 'connection', (socket) ->

  #// Emit a message to send it to the client.
  require("./app/uni_ramp_feed")(socket)

  #// Print messages from the client.
  socket.on 'pong', (data) ->
    console.log(data.msg)
