require 'rubygems'
require 'webrick'
require 'dbi'

class AlcoholServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    status, content_type, body = getResponse request# call some method that returns a status, a contenttype, and json
    
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
    
  end

  def do_POST(request, response)
    status, content_type, body = getResponse request # call some method that returns a status, a contenttype, and json
  
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end
  def getResponse request
    begin
      
      return 200, "text/plain", "COCKS"
    rescue Exception=>e
      
      return 500, "text/plain", "COCKS"
    end
  end
end
