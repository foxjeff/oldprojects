require 'arl_telematics.rb'
module ARL_Telematics

	require 'webrick'

	include WEBrick
	#c=CommandAndControl.new
	#c.connect_consoles
	#sleep 0.5
	#c.connect_cncs
	#c.connect_ivtu_cnc
	#c.handle_commands
	@@cnc_thread = nil
		@@schedule = "fred_flinstone"
		def self.schedule=(schedule)
			puts "schedule set to: #{schedule}"
			@@schedule = schedule
		end
		def self.schedule
			@@schedule
		end
	class CnCServlet < HTTPServlet::AbstractServlet
		include ARL_Telematics
		include MonitorMixin

		### should be a singleton
		#@@schedule = "flinstone"
		@@bus_status = "rubble"
		@@scenario_files = []
		@@current_scenario = nil
		@@testing = false
		@@cnc = nil
		@@log_string = ""
		@@log_string.extend(MonitorMixin)
		@@tail_foo_thread = nil
		@@cnc_pid = nil

		def initialize(arg)
			initialize_cnc
		end

		#def CnCServlet.schedule=(schedule)
			#puts "schedule set to: #{schedule}"
			#@@schedule = schedule
		#end
		def CnCServlet.bus_status=(status)
			@@bus_status = status
			puts "bus_status set to: #{status}"
		end
		def do_GET(req, resp)   
			case req.query['command']
			when "schedule"
				resp.body = "#{ARL_Telematics::schedule}"
				raise HTTPStatus::OK
			when "status"
				resp.body = "#{@@bus_status}"
				raise HTTPStatus::OK
			when "set_testing"
				@@testing = req.query['testing'] == 'true' ? true : false;
				puts "in set_testing, @@testing = #{req.query['testing']}"
				@@cnc.testing = @@testing
				resp.body = @@testing == true ? 'true':'false'
				raise HTTPStatus::OK
			when "set_scenario"
				scenario_number = req.query['scenario'].to_i; 
				@@current_scenario = @@scenario_files[scenario_number]
				puts "calling @@cnc.scenario= for scenario #{@@current_scenario}"
				@@cnc.scenario_file = @@current_scenario
				sc = @@current_scenario.split "-"
				if @@cnc_thread != nil
					@@cnc.load_scenario
				end
				resp.body = "#{sc[1]} vehicle, #{sc[3]} route"
				raise HTTPStatus::OK
			when "choose_scenario"
				resp.body = "<select id='scenarios' name='scenarios'>"
				Dir.glob("scenarios-?-vehicles-?-routes*.yaml") {|f| @@scenario_files << f} if @@scenario_files.size == 0
				@@scenario_files.each_with_index do
					|f, i|
					if i == 1
						resp.body << "<option selected value=#{i}>#{f}</option>"
					else
						resp.body << "<option value=#{i}>#{f}</option>"
					end
				end
				resp.body << "</select>"
				raise HTTPStatus::OK
			when "start_cnc"
				if @@current_scenario == nil
					resp.body = "CnC NOT started; must have a scenario loaded first."
				else
					puts "in start_cnc,@@cnc = #{@@cnc}, @@cnc_pid = #{@@cnc_pid}"
					#kill_cnc_thread(@@cnc, @@cnc_thread) if @@cnc_thread 
					Process.kill(9,@@cnc_pid) if @@cnc_pid
					#@@cnc_thread = Thread.new { start_cnc }
					puts "forking now"
					@@cnc_pid = fork { 
						#at_exit {exit!}
						#at_exit {puts "child(#{$$}) death"} 
						@@cnc.cnc_servlet = self
						start_cnc
					}
					at_exit {puts "parent(#{$$}) death"} 
					puts "detaching now"
					puts "process: #{Process.detach @@cnc_pid}" # -> #{$?.exitstatus}"
					resp.body = "CnC (re)Started (#{@@cnc} ... #{@@cnc_pid})"
				end
				raise HTTPStatus::OK
			when "start_scenario"
				th=Thread.new { @@cnc.start_scenario } 
				resp.body = "start_scenario with thread: #{th}"
				raise HTTPStatus::OK
			when "tail_foo"
				@@tail_foo_thread = Thread.new { tail_foo } unless @@tail_foo_thread
				@@log_string.extend(MonitorMixin)
				@@log_string.synchronize do
					resp.body = @@log_string
					@@log_string = ""
				end
				raise HTTPStatus::OK

			else
				raise HTTPStatus::PreconditionFailed.new( "missing proper key: 'cnc'")
			end
		end
		def tail_foo
			File.open('foo2') do
				|log| log.extend File::Tail
					log.tail do
						|line| 
						@@log_string.extend(MonitorMixin)
						@@log_string.synchronize do
							@@log_string << line 
						end
					end
				end
		end
		def initialize_cnc
			# always start with a scenario loaded
			puts "in initialize_cnc,testing is: #{@@testing? 'true':'false'}, and @@current_scenario = #{@@current_scenario} "
			@@cnc = ARL_Telematics::CommandAndControl.new unless @@cnc !=nil
			@@cnc.cnc_servlet = self
			@@cnc.testing = @@testing
			@@cnc.scenario_file = @@current_scenario
		end
		def start_cnc
			puts "starting tdcs_tgate_ivtu"
			@@cnc.start_tdcs_tgate_ivtu
			@@cnc.start_scenario
			sleep 10000.0
			puts "done sleeping"
		end

		alias do_POST do_GET    # let's accept POST request too.
	end # end class CnCServlet
end
