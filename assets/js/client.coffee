self = {} unless self?
@enoc = self
self.socket = io.connect(window.location.protocol + "//" + window.location.host)

self.markers = {}
self.day = new Date(2012,0,1)

self.get_day = () ->
  self.socket.emit "get_day",
    key: "#{self.day.getUTCMonth()}#{self.day.getUTCDay()}"


self.socket.on "day", (data) ->
  console.log "day!"
  for site in data.sites
    self.update_marker site
  self.day.setTime self.day.getTime + 60000 * 60 * 24
  window.setTimeout self.get_day, 1000


self.socket.on "sites", (data) ->
  for site in data.sites
    self.add_marker site

self.socket.on "test", (d) ->
  console.log "Socket test!", d


self.get_sites = () ->
  socket.emit 'sites'

self.play = (evt) ->
  console.log "Play!"
  self.day = new Date(2012,0,1)
  self.get_day


self.stop = (evt) ->
  console.log "Stop!"
  self.socket.emit "stop"


self.add_marker = (site) ->
  marker = new google.maps.Marker(
    position: new google.maps.LatLng(site.lat,site.lng)
    icon: {
      path: google.maps.SymbolPath.CIRCLE
      fillOpacity: 0.5
      fillColor: '00ff00'
      strokeOpacity: 1.0
      strokeColor: 'fff000'
      strokeWeight: 3.0
      scale: 20 #pixels
    }
  map: self.map)
  self.markers[site.id] = marker


self.update_marker = (site) ->
  existing = self.markers[site.id]
  existing.icon.strokeColor = site.usage.toString(16)


self.init = ->
  console.log "Init!"
  $('#play-btn').on 'click', self.play
  $('#stop-btn').on 'click', self.stop

  self.map = new google.maps.Map($("#map")[0],
    scrollwheel: false
    styles: self.mapStyles
    center: new google.maps.LatLng(33,-98)
    zoom: 5
    mapTypeId: google.maps.MapTypeId.ROADMAP
    mapTypeControlOptions: {
      style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
    }
    zoomControlOptions: {
      style: google.maps.ZoomControlStyle.SMALL
    }
    streetViewControl: false
  )
  google.maps.event.addListenerOnce self.map, "tilesloaded", (evt) ->
    self.get_sites()

  $(window).on "resize orientationChanged", self.adjust_map_bounds
  self.adjust_map_bounds()


self.adjust_map_bounds = ->
  map = $("#map")
  map.height window.innerHeight - 40
  map.width = $(document.body).width()


self.mapStyles = [
  { featureType: "all", stylers: [ saturation: 50 ] },
  { featureType: 'administrative', stylers: [] },
  { featureType: 'all', elementType: 'labels' },
  { featureType: "road", stylers: [
      { hue: "#00ffee" },
      { lightness: 10 },
      { saturation: -80 }
    ]
  },
  { featureType: "water", stylers: [
      { saturation: -70 },
      { lightness: -50 }
    ]
  },
  { featureType: 'poi', stylers: [
      { saturation: -50 }
    ]
  },
  # POIs create clickable labels that can't be intercepted...
  { featureType: "poi", elementType: "labels", stylers: [ { visibility: "off" } ] }
]
