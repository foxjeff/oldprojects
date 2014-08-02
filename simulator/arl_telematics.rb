
module  ARL_Telematics
	require 'CommandAndControl.rb'
	require 'cnc-web-interface.rb'

	require 'monitor'
	require 'rubygems'
	require 'file/tail'
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
	def kill_cnc_thread(cnc, thread)
		puts "in kill_cnc, cnc = #{cnc}, thread = #{thread}, #{thread.status}"
		# try sending a quit to cnc
		#cnc.quit_scenario
		if thread.exit == thread
			thread.exit
			puts "thread killed on second try #{thread.status}"
		else
			puts "thread killed on first try #{thread.status}"
		end
	end
	def self.start_webrick(config = {})
		# always listen on port 8080
		config.update(:Port => 2000)     
		config.update(:Document_root => Dir::pwd)
		server = HTTPServer.new(config)
		yield server if block_given?
		['INT', 'TERM'].each {|signal| 
			trap(signal) {server.shutdown}
			kill_cnc_thread if @@cnc_thread
		}
		server.start
	end
		
	$hello = HTTPServlet::ProcHandler.new(hello_proc)
	$bye   = HTTPServlet::ProcHandler.new(bye_proc)

	puts "starting webrick"
	#Thread.new { start_webrick {
		#|server| 
		#server.mount("/", HTTPServlet::FileHandler, Dir.pwd, {:FancyIndexing=>true})
		#server.mount("/hello", $hello)
		#server.mount("/bye", $bye)
		#server.mount("/simulator", CnCServlet)
		#}
	#}
	ARL_Telematics.start_webrick() {
		|server|
		server.mount("/cnc", CnCServlet)
		server.mount("/", HTTPServlet::FileHandler, Dir.pwd, {:FancyIndexing=>true})
	}


end
