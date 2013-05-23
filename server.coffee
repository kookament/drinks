fs = require 'fs'
_ = require 'underscore'
express = require 'express'
handlebars = require 'handlebars'
connect_coffee_script = require 'connect-coffee-script'
connect_less = require 'connect-less'
connect_handlebars = require 'connect-handlebars'
url = require 'url'

search = require './api/search.coffee'

PORT = 3000

app = express()

# Resources -------------------------------------
# Why does binding this to /scripts not work?
app.use '/', connect_coffee_script
  src: __dirname + '/coffeescript'
  dest: __dirname + '/compiler-cache'

app.use '/', connect_less
  src: __dirname + '/less'
  dst: __dirname + '/compiler-cache'

app.use '/templates.js', connect_handlebars __dirname + '/handlebars'

app.use express.static(__dirname + '/javascript')
app.use express.static(__dirname + '/css')
app.use express.static(__dirname + '/img')

app.use express.static(__dirname + '/compiler-cache')

# Root ------------------------------------------
app.get '/', (req, res) ->
  # Move this out when we aren't in 'dev mode' anymore.
  root_html = handlebars.compile(fs.readFileSync 'root.handlebars', 'utf-8')
  scripts = _.chain(fs.readdirSync './coffeescript')
    .filter((f) -> f.match /\.coffee$/)
    .map((f) -> f.replace /\.coffee$/, '.js')
    .value()
  styles = _.chain(fs.readdirSync './less')
    .filter((f) -> f.match /\.less$/)
    .map((f) -> f.replace /\.less$/, '.css')
    .value()
  res.send root_html(scripts: scripts, styles: styles)

# API -------------------------------------------
app.get '/api', (req, res, next) ->
  console.log 'request', req.url, req.params
  next()

app.get '/api/search', (req, res, next) ->
  params = url.parse(req.url, true).query
  res.send search.search(params)

app.get '/api/tags', (req, res, next) ->
  params = url.parse(req.url, true).query
  res.send search.tags(params?.tags)

app.get '/api/recipes', (req, res) ->
  params = url.parse(req.url, true).query
  res.send 'not yet implemented'

search.index()

app.listen PORT
console.log "drinks server listening on port #{PORT}"
