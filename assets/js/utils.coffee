@utils ?= {}
  
###
Node builder.  Call like:
n('div',{class:'top'},'inner text') // or:
n('div',{class:'top'},[n('p',{},'nested element'])
###
@utils.n = (e, attrs, inner) ->
  e = document.createElement(e)  if typeof (e) is "string"
  if attrs
    for k of attrs
      e.setAttribute k, attrs[k]
  if inner
    if typeof (inner) is "string"
      e.textContent = inner
    else if inner.call
      inner.call e
    else
      for i of inner
        e.appendChild inner[i]
  $ e


###
Tweet tmpl:
http://mir.aculo.us/2011/03/09/little-helpers-a-tweet-sized-javascript-templating-engine/
Call it like this:
t("Hello {who}!", { who: "JavaScript" });
###
@utils.t = (s, d) ->
  for p of d
    s = s.replace(new RegExp("{" + p + "}", "g"), d[p])
  s

@utils.relativeTime = (from) ->
  MIN = 60
  HOUR = MIN * 60
  DAY = HOUR * 24
  WEEK = DAY * 7
  MONTH = DAY * 30
  YEAR = DAY * 365
  if typeof (from) is "string"
    from = new Date(from).getTime()
  else from = from.getTime()  if typeof (from) is "object"
  diff = (new Date().getTime() - from) / 1000
  pastPresent = " ago"
  if diff < 0
    pastPresent = " from now"
    diff = Math.abs(diff)
  return "just now"  if diff < 1
  if diff < MIN
    amount = diff
    unit = " second"
  else if diff < HOUR
    amount = diff / MIN
    unit = " minute"
  else if diff < DAY
    amount = diff / HOUR
    unit = " hour"
  else if diff < WEEK
    amount = diff / DAY
    unit = " day"
  else if diff < MONTH
    amount = diff / WEEK
    unit = " week"
  else if diff < YEAR
    amount = diff / MONTH
    unit = " month"
  else
    amount = diff / YEAR
    unit = " year"
  "" + Math.floor(amount) + unit + ((if amount < 2 then "" else "s")) + pastPresent


# make text look like it's being typed on the screen :)
@utils.typewriter = (dest, text, currentChar, delay) ->
  dest.html text.substr(0, currentChar++)
  if currentChar > text.length # we are done
    return
  else
    setTimeout (->
      app.typewriter dest, text, currentChar, delay
    ), delay

@utils.scrollTo = (selector) ->
  offset = $(selector).offset()
  $("html, body").animate
    scrollTop: offset.top - 30
    scrollLeft: offset.left - 20


@utils.globalPatches = ->
  if typeof (Function::curry) is "undefined"
    Function::curry = ->
      fn = this
      args = Array::slice.call(arguments)
      ->
        fn.apply this, args.concat(Array::slice.call(arguments))

  if typeof (Function::partial) is "undefined"
    Function::partial = ->
      fn = this
      args = Array::slice.call(arguments)
      ->
        arg = 0
        i = 0

        while i < args.length and arg < arguments_.length
          args[i] = arguments_[arg++]  if args[i]?
          i++
        fn.apply this, args

  window.localStorage = {}  unless window.localStorage

  # Stub for conole.log for browsers that don't have support
  unless window.console
    methods = "debug,error,exception,info,log,trace,warn".split(",")
    console = {}
    l = methods.length
    fn = ->

    console[methods[l]] = fn  while l--
    window.console = console
