# EnerNOC Open Data Demo

This is a demo app that was built by [@thom\_nic](https://twitter.com/thom_nic) in about 
8 hours for the 2013 [Boston CleanWeb Hackathon](http://boston.cleanwebhack.com/).  It 
visualizes energy usage data from [EnerNOC Open](http://open.enernoc.com/data).

![Screenshot!](https://github.com/EnerNOC/open-data-map/raw/master/screenshot.png)


## Installation

[![build status](https://secure.travis-ci.org/EnerNOC/open-data-map.png)](http://travis-ci.org/EnerNOC/open-data-map)

The app uses [Node.js](http://nodejs.org), CoffeeScript and [Redis](http://redis.io) > 2.6.

Recommended installation procedure from Mac with [Homebrew](http://mxcl.github.io/homebrew/):

    brew update
    brew install node
    brew install redis
    
    # install global Node modules:
    npm install -g coffee-script
    npm install -g nodemon

    # clone repo:
    git clone git://github.com/EnerNOC/open-data-map.git
    cd open-data-map
    npm install # install project dependencies

Then go to the `import` directory and follow those [README instructions](import/README.md)

Also, it might be good to get a Maps API key - see [keys.js](keys.js)

Assuming you've done all that, you can use `nodemon` or just `coffee server.coffee` to 
run the server!  Browse to `http://localhost:8888` to (hopefully) see it running.


## Deployment

TODO - this should deploy easily to [OpenShift](http://openshift.redhat.com/) with a DIY
cartridge.


## Credits

Things that are awesome:

* [Node.js](http://nodejs.org/)
* [CoffeeScript](http://coffeescript.org/)
* [Twitter Bootstrap](http://twitter.github.com/bootstrap/)
* [Font-Awesome](http://fortawesome.github.com/Font-Awesome/)
* [Socket.io](http://socket.io/)
* [cdnjs](http://cdnjs.com/)
* [Redis](http://redis.io)
* [OpenShift](http://openshift.redhat.com/)
* [Homebrew](http://mxcl.github.io/homebrew/)
* ... and much more
