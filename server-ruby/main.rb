__DIR__ = File.dirname(__FILE__);
$db = __DIR__ + "/db/"
$model = __DIR__ + "/model/"
$servlet = __DIR__ + "/servlet/"

require 'rubygems'
require 'webrick'
require 'dbi'
require $servlet + 'AlcoholServlet'

if $0 == __FILE__ then
  server = WEBrick::HTTPServer.new(:Port => 8007)
  server.mount "/boozahols", AlcoholServlet
  trap "INT" do server.shutdown end
  server.start
  
end
