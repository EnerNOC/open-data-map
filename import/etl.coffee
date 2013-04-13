csv = require 'csv'
fs = require 'fs'
yaml = require 'js-yaml'
redis = require "redis"
config = require '../config'

# Note: this can easily swamp Redis, recommended you
# add the following to redis.conf:
# save ""
# which basically turns of filesystem persistence (it's all in-memory!)

meta = require "#{__dirname}/meta/all_sites.yaml"

p = console.log
red = redis.createClient config.redis_opts.port, config.redis_opts.host
red.on "error", (err) ->
  console.log "Error: #{err}"
red.on "drail", (err) ->
  console.log "Error: #{err}"

days = {}
finished_list = []

processFile = (f) ->
  return unless f.search( '.csv' ) > 0
  site_id = f.split('.')[0]
  p f, site_id
  tzo = parseInt( meta[site_id]['tzo'].split(':')[0] ) * 60000

  count = 0
  csvStream = csv().from.stream(fs.createReadStream("csv/#{f}"))
  csvStream.on( 'record', (row,index) ->
    return if isNaN parseInt(row[0])
#      p "#{index}: #{JSON.stringify(row)}"
    ts = new Date(parseInt(row[0])*1000 + tzo)
    red.hincrby "#{ts.getUTCMonth()}/#{ts.getUTCDate()}", site_id,
      Math.round( parseFloat( row[2] )*1000 )
    count+=1
    if count % 288 == 0
      p( "Slow down!" ) if red.command_queue.length # means there is TCP backpressure
      p "#{site_id}: #{count}"

  ).on( 'end', (count) ->
    finished_list << site_id
  )

  csvStream.on 'end' (rowCount) ->
    p "Done with #{site_id}, total count: #{rowCount}"

fs.readdir 'csv', (err,files) ->
  processFile f for f in files


