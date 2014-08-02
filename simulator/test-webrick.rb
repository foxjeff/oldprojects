#!/usr/bin/env ruby 

require 'webrick' 
include WEBrick 
 
hello_proc = lambda do
	|req, resp| 
	resp['Content-Type'] = "text/html" 
	resp.body = %{ 
		<html><body> 
		Hello. You're calling from a #{req['User-Agent']} 
		<p> 
		I see parameters: #{req.query.keys.join(', ')} 
		</body></html> 
	} 
end 

bye_proc = lambda do
	|req, resp| 
	resp['Content-Type'] = "text/html" 
	resp.body = %{ 
		<html><body> 
		<h3>Goodbye!</h3> 
		</body></html> 
	} 
end 
class GreetingServlet < HTTPServlet::AbstractServlet
  def do_GET(req, resp)   
    if req.query['name']
      resp.body = 
        "#{@options[0]} #{req.query['name']}. #{@options[1]}"
      raise HTTPStatus::OK
    else
      raise HTTPStatus::PreconditionFailed.new(
        "missing attribute: 'name'")
    end
  end
  alias do_POST do_GET    # let's accept POST request too.
end

def start_webrick(config = {})
  # always listen on port 8080
  config.update(:Port => 2000)     
  server = HTTPServer.new(config)
  yield server if block_given?
  ['INT', 'TERM'].each {|signal| 
    trap(signal) {server.shutdown}
  }
  server.start
end
  
hello = HTTPServlet::ProcHandler.new(hello_proc)
bye   = HTTPServlet::ProcHandler.new(bye_proc)

start_webrick {
	|server| 
	server.mount('/greet', GreetingServlet, 'Hi', 'Are you having a nice day?')
	server.mount("/", HTTPServlet::FileHandler, Dir.pwd, {:FancyIndexing=>true})
	server.mount("/hello", hello)
	server.mount("/bye", bye)
}

#s = HTTPServer.new(:Port => 2000, :DocumentRoot => Dir.pwd) 
#s.mount("/hello", hello) 
#s.mount("/bye", bye) 
#s.mount("/greet", GreetingServlet, 'Hi', 'Are you having a nice day?') 

#trap("INT"){ s.shutdown } 
#s.start 

