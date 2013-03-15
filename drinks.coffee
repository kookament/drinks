node33 = require 'node33'

PORT = 3001

app = node33.server(
  [
    './plugins/lib',
    './plugins/drinks'
  ],
  node33.parsers.jsonPlugin,
  node33.compilers.jsonPluginCompilers
)

app.listen PORT
console.log "node33 server listening on port #{PORT}."
