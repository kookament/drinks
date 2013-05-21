fs = require 'fs'
_ = require 'underscore'
express = require 'express'
handlebars = require 'handlebars'
connect_coffee_script = require 'connect-coffee-script'
connect = require 'connect'

PORT = 3000

app = express()

# Why does binding this to /scripts not work?
app.use '/', connect_coffee_script
  src: __dirname + '/coffeescript'
  dest: __dirname + '/compiler-cache'

app.use express.static(__dirname + '/javascript')
app.use express.static(__dirname + '/compiler-cache')

app.get '/', (req, res) ->
  # Move this out when we aren't in 'dev mode' anymore.
  root_html = handlebars.compile(fs.readFileSync 'root.handlebars', 'utf-8')
  scripts = _.chain(fs.readdirSync './coffeescript')
    .filter((f) -> f.match /\.coffee$/)
    .map((f) -> f.replace /\.coffee$/, '.js')
    .value()
  scripts = scripts.concat _.chain(fs.readdirSync './javascript')
    .filter((f) -> f.match /\.js$/)
    .value()
  res.send root_html(scripts: scripts)

app.listen PORT
console.log "drinks server listening on port #{PORT}"
