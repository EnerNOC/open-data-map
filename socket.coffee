io = require "socket.io"
redis = require "redis"
config = require "./config"
yaml = require 'js-yaml'

meta = require "#{__dirname}/import/meta/all_sites.yaml"

module.exports.listen = (server, sessionStore) ->
  io_client = io.listen(server)

  io_client.sockets.on "connection", (socket) ->
    
    socket.emit "test",
      hello: "world"

    red = redis.createClient(config.redis_opts.port, config.redis_opts.host)

    red.on 'error', (err) ->
      console.log "Redis error: #{err}"

    socket.on 'sites', () ->
      console.log "Sites!"
      red.getall "01", (err,resp) ->
        socket.emit resp

    socket.on "get_day", (data) ->
      console.log "Day!", socket.id, data
      red.getall data.day, (err,resp) ->
        console.log err,resp
        socket.emit "day", resp

    socket.on "disconnect", ->
      console.log "client disconnecting"
      red.quit() if red?
