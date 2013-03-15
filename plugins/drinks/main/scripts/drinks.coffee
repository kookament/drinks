node33 = require '../node33'

PORT = 3001

app = node33.server(
  [
    '/Users/skelley/src/drinks'
  ],
  node33.parsers.jsonPlugin,
  node33.compilers.code33compilers
)

app.listen PORT
console.log "node33 server listening on port #{PORT}."
