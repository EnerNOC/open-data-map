self = {} unless self?
@enoc = self
self.socket = io.connect(window.location.protocol + "//" + window.location.host)

self.markers = {}
self.day = new Date(2012,0,1)
self.stop = false

sq_ft_min = 500
sq_ft_max = 1500000
sq_ft_range = sq_ft_max - sq_ft_min
icon_scale_min = 5
icon_scale_max = 20
icon_scale_range = icon_scale_max - icon_scale_min

self.get_icon_size = (sq_ft) ->
  parseInt (sq_ft - sq_ft_min) / sq_ft_range * icon_scale_range + icon_scale_min


usage_min = 20e3
usage_max = 30e6
usage_range = usage_min - usage_max
hsl_min = 190
hsl_max = 360
hsl_range = hsl_max - hsl_min

self.get_HSL = (val) ->
  v = parseInt( (val - hsl_min) / usage_range * hsl_range + hsl_min )
  "hsl(#{v},100%,50%)"


self.get_day = () ->
#  console.log "Day #{self.day}"
  self.socket.emit "get_day",
    key: "#{self.day.getMonth()}#{self.day.getDate()}"


self.socket.on "day", (data) ->
#  console.log "day!"
  for id,reading of data
    self.update_marker id,reading
  $('#date').text self.day.toDateString()
  self.day.setTime self.day.getTime() + 60000 * 60 * 24
  window.setTimeout self.get_day, 1000 unless self.stop


self.get_sites = () ->
  console.log "Get Sites!"
  for id,marker of self.markers
    marker.setMap null
    delete self.markers[ id ]
  self.socket.emit 'sites'


self.socket.on "sites", (sites) ->
#  console.log "Sites!", sites
  for id, site of sites
    self.add_marker id, site


self.add_marker = (id, site) ->
  marker = new google.maps.Marker(
    position: new google.maps.LatLng(site.lat_lng...)
    icon: {
      path: google.maps.SymbolPath.CIRCLE
      fillOpacity: 0.5
      fillColor: '#6e1' #'#19a'
      strokeOpacity: 0.8
      strokeColor: '#666'
      strokeWeight: 1.2
      scale: self.get_icon_size(site.sq_ft) #5 #pixels
    }
    animation: google.maps.Animation.DROP
    map: self.map)
  site.id = id
  site.current_usage = "?"
  marker.site_info = site
  google.maps.event.addListener marker, "click", self.marker_clicked
  self.markers[id] = marker


self.marker_clicked = (evt) ->
#  console.log "click", this
#  console.log "Marker clicked for site #{this.site_info.id}"
  self.selected_site_id = this.site_info.id
  self.infoBubble.close() if self.infoBubble.isOpen()
  self.infoBubble.setPosition new google.maps.LatLng(this.site_info.lat_lng...)
  self.infoBubble.setContent ich.markerWindow( this.site_info )[0]
  self.infoBubble.open()


self.update_marker = (id,val) ->
  marker = self.markers[id]

  usage = (val/1000).toString()
  usage = usage.split( usage.indexOf('.') + 2 )[0]
  marker.site_info.current_usage = usage
  if id == self.selected_site_id
    $('.info .usage').text usage # updated current usage

  color = self.get_HSL parseInt( val )
#  console.log "setting color: #{color}"
  marker.icon.fillColor = color
  marker.notify 'icon'


self.play = (evt) ->
  console.log "Play!"
  self.stop = false
  self.day = new Date(2012,0,1)
  self.get_day()


self.stop = (evt) ->
  console.log "Stop!"
  self.stop = true
  self.socket.emit "stop"


self.socket.on "test", (d) ->
  console.log "Socket test!", d


self.init = ->
  console.log "Init!"
  $('#play-btn').on 'click', self.play
  $('#stop-btn').on 'click', self.stop
  $('#refresh-btn').on 'click', self.get_sites

  self.map = new google.maps.Map($("#map")[0],
    styles: self.mapStyles
    center: new google.maps.LatLng(34,-98)
    mapTypeId: google.maps.MapTypeId.ROADMAP
    zoom: 4
    scrollwheel: false
    panControl: false
    mapTypeControl: false
    zoomControlOptions: {
      style: google.maps.ZoomControlStyle.SMALL
    }
    streetViewControl: false
  )

  self.infoBubble = new InfoBubble(
      map: self.map
      borderRadius: 6
      arrowSize: 10
      borderWidth: 2
      borderColor: '#ccc'
      arrowPosition: 30
      arrowStyle: 0
      disableAutoPan: true
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
  { featureType: 'administrative', elementType: "labels", stylers: [{visibility:"off"}] },
  { featureType: 'administrative.land_parcel', stylers: [{visibility:"off"}] },
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
      { visibility: off }
    ]
  },
  { featureType: 'landscape', stylers: [ { visibility: "off" } ] },
  # POIs create clickable labels that can't be intercepted...
  { featureType: "poi", stylers: [ { visibility: "off" } ] }
]
