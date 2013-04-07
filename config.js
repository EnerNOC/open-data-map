var env = process.env
  , keys = require('./keys')

module.exports = {
	redis_opts : {
		host : process.env.REDIS_IP || 'localhost',
		port : process.env.REDIS_PORT || 6379
	},
	layout_vars : {
		maps_api_key : keys.maps_api_key,
	},
	debug : ! env.OPENSHIFT_GEAR_DNS,
	listen_port : parseInt(process.env.OPENSHIFT_INTERNAL_PORT) || 8888,
	listen_ip : process.env.OPENSHIFT_INTERNAL_IP || "127.0.0.1",
}
