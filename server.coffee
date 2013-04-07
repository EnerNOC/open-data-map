express = require("express")
app = express()
server = require("http").createServer(app)
path = require("path")
assets = require('connect-assets')
config = require("./config")
keys = require('./keys')
socket = require("./socket").listen(server)

app.configure ->
  app.set "views", path.join(__dirname, "views")
  app.set "view engine", "jade"
  app.use express.logger()
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use assets()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.get "/", (req, res) ->
  res.render "index", maps_api_key : keys.maps_api_key

quit = (sig) ->
  if typeof sig is "string"
    console.log "%s: Received %s - terminating Node server ...", Date(Date.now()), sig
    process.exit 1
  console.log "%s: Node server stopped.", Date(Date.now())

# Process on exit and signals.
process.on "exit", ->
  quit()

"HUP,INT,QUIT,TERM".split(",").forEach (sig, i) ->
  process.on "SIG#{sig}", ->
    quit "SIG#{sig}"

# Run server  
server.listen config.listen_port, config.listen_ip, ->
  console.log "%s: Node (version: %s) %s started on %s:%d ...", Date(Date.now()), process.version, process.argv[1], config.listen_ip, config.listen_port

