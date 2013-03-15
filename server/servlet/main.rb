require 'rubygems'
require 'webrick'
require 'dbi'
require 'AlcoholServlet'

# Initialize our WEBrick server
if $0 == __FILE__ then
  server = WEBrick::HTTPServer.new(:Port => 8007)
  server.mount "/boozahols", AlcoholServlet
  trap "INT" do server.shutdown end
  server.start
end
