#!/usr/bin/env ruby -w
#
require 'arl_telematics.rb'

require 'monitor'

module ARL_Telematics
	class CommandAndControl < Monitor
		#require 'tdcs_simulator.rb'
		#require 'tgate_simulator.rb'
		#require 'ivtu_simulator.rb'
		require 'simulator'
		require 'scenarios'

		include ARL_Telematics
		include Simulator
		include Socket::Constants
		include HighLine::SystemExtensions
		include Scenarios

		attr_accessor	:tdcs_console_session
		attr_accessor	:tdcs_console_socket
		attr_accessor	:tdcs_control_socket

		attr_accessor	:tgate_console_session
		attr_accessor	:tgate_console_socket
		attr_accessor	:tgate_control_socket

		attr_accessor	:ivtu_console_session
		attr_accessor	:ivtu_console_socket
		attr_accessor	:ivtu_control_socket

		attr_accessor	:timeline
		attr_accessor	:vehicles
		attr_accessor	:scenario
		attr_accessor	:nodes
		attr_accessor	:name

		attr_accessor :scenario_time 
		attr_accessor :paused_delta 
		attr_accessor	:timeline_thread
		attr_accessor	:bus_status_thread
		attr_accessor	:timeline_paused

		attr_accessor :testing
		attr_accessor :scenario_file # yaml_file

		attr_accessor :tdcs
		attr_accessor :tgate
		attr_accessor :ivtu
		attr_accessor :cnc_servlet

		Scenario_timeline_sleep = 10

		def initialize
			self.testing = false
			self.timeline = nil
			Thread.abort_on_exception = true # *** take for production ***
			self.timeline_thread = nil
			self.timeline_paused = nil
			self.bus_status_thread = nil
			self.scenario = Scenario.new
			@scenario_time = Time.at(0)
			#@scenario_time.extend(MonitorMixin)
			super
		end
		def start_tdcs_tgate_ivtu
			#puts "starting tdcs"
			#Thread.new{self.tdcs = Acceptor.new}
			#puts "starting ivtu"
			#Thread.new{self.ivtu = IVTU_simulator.new}
			#puts "starting tgate"
			#Thread.new{self.tgate = TGate_simulator.new}
			#connect_consoles
			#sleep 0.5
			puts "connecting cncs"
			Thread.new { connect_cncs }
			load_scenario
			# for tdcs startup:
			#Thread.new { tdcs.accept }	#{ handle_command_input }
			#Thread.new { tdcs.check_vehicles }
		end
		def quit_scenario
			puts "going away now..."
			raise "Boom"
			#ivtu_control_socket.puts "quit" unless testing
			#tgate_control_socket.puts "quit" unless testing
			#tdcs_control_socket.puts "quit" unless testing
			#Kernel::exit(true)
		end
		def load_scenario 
			@timeline_paused = true
			scenario.load_routes scenario_file
			puts "in @@cnc.load_scenario, load file: #{scenario_file}"
			puts "in load_scenario: tl_paused: #{@timeline_paused? "true":"false"}, sc: #{scenario} tl_th: #{@timeline_thread}}"
			tdcs_control_socket.puts "scenario_file:#{scenario_file}" unless testing
			vehicles = scenario.vehicles.flatten
			vehicles.each do
				|v|
				ivtu = "create_ivtu:"
				ivtu += "#{v['code']},#{v['lic']}}"
				ivtu_control_socket.puts ivtu unless v['code'] =~ /V010/ unless testing
			end
			@timeline_thread = Thread.new { process_timeline } if scenario
			@bus_status_thread = Thread.new { update_bus_status } if scenario
			puts "in load_scenario: tl_paused: #{@timeline_paused? "true":"false"}, sc: #{scenario} tl_th: #{@timeline_thread}}"
			#p vehicles
			#return
			#self.vehicles = scenario.vehicles
			#self.nodes = scenario.nodes
			#self.name = scenario.name
			#self.nodes.flatten!
			#self.vehicles.flatten!
			#puts "creating itvus"
			#puts "sending route_info to tdcs"
			#tdcs_control_socket.puts "route_info:#{nodes.inspect}|#{vehicles.inspect}|#{name}" unless testing
		end
		def process_timeline
			self.timeline = scenario.build_timeline
			create_schedule
			times = timeline.clone 
			@scenario_time =Time.now
			loop do
				Thread.stop if @timeline_paused
				events = []
				#puts "top of process_timeline, #{times.size}"
				times_delete_count = 0
				break if times.size == 0
				times.each do
					|e|
					if @scenario_time > e[0] - 10 
						puts("processing: #{e[0]} @#{@scenario_time.strftime('%H:%M:%S')}")
						#p e[1]
						events << e[1] 
						times_delete_count += 1
					end
				end
				times_delete_count.times {times.shift}
				process_events events if events.size > 0
				sleep Scenario_timeline_sleep
				synchronize do
					p @scenario_time += Scenario_timeline_sleep
				end
			end
			puts "Scenario is finished."
		end
		def process_events(events)
			events.each do
				|e|
				tgate_control_socket.puts "pairs:{\"#{e['vehicle']}\" => \"#{e['station']}\"}" unless e['evt'] =~ /departure/i unless testing
				if e['evt'] =~ /arrival/i
					ivtu = "startup:"
				else
					ivtu = "shutdown:"
				end
				ivtu += e['vehicle']
				ivtu_control_socket.puts ivtu unless e['vehicle'] =~ /V010/ unless testing
			end
			#p tgate_message
		end
		def get_tdcs_console
			while msg = tdcs_console_session.readline.chomp
				puts msg
				#sleep 1
			end
		end
		def get_tgate_console
			while msg = tgate_console_session.readline.chomp
				puts msg
				#sleep 1
			end
		end
		def get_ivtu_console
			while msg = ivtu_console_session.readline.chomp
				puts msg
				#sleep 1
			end
		end
		def connect_cncs
			#self.tdcs_control_socket = TCPSocket.new(CnC_IP, TDCS_CnC_PORT) unless testing
			puts "in cnc connect_cnc, testing is #{self.testing ? 'true':'false'}"
			self.tdcs_control_socket = TCPSocket.new(CnC_IP, TDCS_CnC_PORT)
			self.tgate_control_socket = TCPSocket.new(CnC_IP, TGATE_CnC_PORT)
			# ***
			self.ivtu_control_socket = TCPSocket.new(CnC_IP, IVTU_CnC_PORT) unless testing
		end
		def connect_consoles
			self.tdcs_console_socket = TCPServer.new(CnC_IP, TDCS_CONSOLE_PORT) unless testing
			self.tgate_console_socket = TCPServer.new(CnC_IP, TGATE_CONSOLE_PORT) unless testing
			self.ivtu_console_socket = TCPServer.new(CnC_IP, IVTU_CONSOLE_PORT) unless testing
		end
		def shutodwn
			ivtu_control_socket.puts "quit" unless testing
			tgate_control_socket.puts "quit"# unless testing
			tdcs_control_socket.puts "quit" # unless testing
			Kernel::exit(true)
		end
		def start_scenario
			if @timeline_paused
				puts "starting/unpausing scenario"
				#do something with paused_delta (like update arr/dep times)
				@paused_delta = @scenario_time - Time.now
				@timeline_paused = false
				@timeline_thread.run
				@bus_status_thread.run
				#Thread.new { update_bus_status } if scenario
				#update_bus_status 
			else
				puts "pausing scenario"
				@scenario_time = Time.now
				@timeline_paused = true
			end
		end
		def handle_commands
			puts "ready for commands" 
			while ( command = get_character )
				case command.chr
					when /l/
						@timeline_paused = true
						scenario_files = []
						Dir.glob("scenarios-?-vehicles-?-routes*.yaml") {|f| scenario_files << f}
						menu_choices = ""
						scenario_files.each {|f| menu_choices += "m.choice " + '"' + f +'"' + "; "}
						yaml_file = choose do
							|m|
							m.header="Choose a Scenario"
							m.prompt = "Which? "
							eval menu_choices
						end
						puts "loading scenario"
						#@timeline_thread.kill if @timeline_thread
						#@timeline_thread.kill if @timeline_thread
						scenario.load_routes yaml_file
						load_scenario yaml_file	#Thread.new { load_scenario }
						@timeline_thread = Thread.new { process_timeline } if scenario
						@bus_status_thread = Thread.new { update_bus_status } if scenario
						puts "Scenario has been loaded:  #{Time.now}"
					when /s/
						if @timeline_paused
							puts "starting/unpausing scenario"
							#do something with paused_delta (like update arr/dep times)
							@paused_delta = @scenario_time - Time.now
							@timeline_paused = false
							@timeline_thread.run
							@bus_status_thread.run
							#Thread.new { update_bus_status } if scenario
							#update_bus_status 
						else
							puts "pausing scenario"
							@scenario_time = Time.now
							@timeline_paused = true
						end
					when /p/
					when /r/
						if scenario.timeline
							puts "starting webrick"
							Thread.new { start_webrick {
								|server| 
								#server.mount("/", HTTPServlet::FileHandler, Dir.pwd, {:FancyIndexing=>true})
								server.mount("/hello", $hello)
								server.mount("/bye", $bye)
								server.mount("/simulator", cnc_servlet)
								}
							}
						else
							puts "need the timeline first"
						end
					when /t/
						puts "tcf was #{self.scenario.tcf}"
						if self.scenario.tcf == 15
							self.scenario.tcf = 60
						else
							self.scenario.tcf = 15
						end
						puts "tcf is now #{self.scenario.tcf}"
					when /q/
						puts "going away now..."
						ivtu_control_socket.puts "quit" unless testing
						tgate_control_socket.puts "quit" unless testing
						tdcs_control_socket.puts "quit" unless testing
						Kernel::exit(true)
					when /\?/
						puts "asking TGate Sim for status"
						tgate_control_socket.puts "tgate_status" unless testing
					when /c/
						begin
							next if tdcs_console_session
							puts "asking tdcs to connect it's console"
							tdcs_control_socket.puts "connect_console" unless testing
							self.tdcs_console_session = tdcs_console_socket.accept unless testing
							puts "tdcs has connected"
							Thread.new { get_tdcs_console } unless testing
						end
						begin
							next if tgate_console_session
							puts "asking tgate to connect it's console"
							tgate_control_socket.puts "connect_console" unless testing
							self.tgate_console_session = tgate_console_socket.accept unless testing
							puts "tgate has connected"
							Thread.new { get_tgate_console } unless testing
						end
						begin
							next if ivtu_console_session
							puts "asking ivtu to connect it's console"
							ivtu_control_socket.puts "connect_console" unless testing
							self.ivtu_console_session = ivtu_console_socket.accept unless testing
							puts "ivtu has connected"
							Thread.new { get_ivtu_console } unless testing
						end
					when /d/
						puts "telling TGate Sim to take it's tcp network down"
						tgate_control_socket.puts "network_down" unless testing
					when /u/
						puts "telling TGate Sim to bring it's tcp network up"
						tgate_control_socket.puts "network_up" unless testing
					else
						puts "hello from Comannd and Control"
				end
			end
		end
		def create_schedule
			schedule = ""
			if self.timeline
				self.timeline.each do
					|k,v|
					schedule += "#{v['station']}_#{v['vehicle']}_#{v['evt']},#{k.strftime('%H:%M')},"
				end
				schedule = schedule.slice(0..-2)
				#ARL_Telematics::CnCServlet.schedule = schedule
				ARL_Telematics.schedule = schedule
				puts "create_schedule: #{schedule}"
			end
		end
		def update_bus_status
			puts "in update_bus_status"
			sleep 0.25 until timeline != nil
			bus_times = timeline.clone
			bus_time = Time.now #scenario_time
			loop do
				Thread.stop if @timeline_paused
				sleep 0.25 until timeline != nil
				bus_times = self.timeline.clone unless bus_times
				#create_schedule
				bus_events = [] 
				bus_times_delete_count = 0
				break if bus_times.size == 0
				bus_times.each do
					|e|
					if bus_time > e[0] - 10 
						puts("bus_event: #{e[1]} @#{e[0].strftime('%H:%M:%S')}")
						bus_events << e 
						bus_times_delete_count += 1
					end
				end
				#puts "bus_times_delete_count: #{bus_times_delete_count}, #{bus_times.size}"
				bus_times_delete_count.times { bus_times.shift }
				#puts "bus_times size: #{bus_times.size}"
				if bus_events.size > 0
					status = prepare_bus_status(bus_events)
				else
					status = "none"
				end
				puts "cnc_servlet: #{cnc_servlet} and status: #{status}"
				ARL_Telematics::CnCServlet.bus_status = status
				sleep Scenario_timeline_sleep
				bus_time += Scenario_timeline_sleep
			end
			ARL_Telematics::CnCServlet.bus_status = "Scenario has finished"
			puts "Bus, Scenario has finished"
		end
		def prepare_bus_status(bus_events)
			status = ""
			bus_events.each do
				|k,v|
				vehicle = "#{v['vehicle']}"
				station_code = "#{v['station']}"
				station = case station_code
					when /t001/i: "TVM"
					when /t002/i: "KLM"
					when /t003/i: "KYM"
					when /t004/i: "ALP"
					when /t005/i: "EKM"
					else "en route"
					end
				status += "#{vehicle}_status,#{v['evt']},#{vehicle}_station,#{station},#{vehicle}_time,#{k.strftime('%H:%M')},"
			end
			puts "prepare_bus_status: #{status}"
			status.slice(0..-2)
		end

	end #class CommandAndControl
end
__END__
[Sun Oct 29 13:36:56 IST 2006, {"vehicle"=>"V003", "evt"=>"arrival", "station"=>"T001"}]
bus_event: vehicleV002evtarrivalstationT001 @13:36:54
bus_event: vehicleV003evtarrivalstationT001 @13:36:54
[Sun Oct 29 13:37:02 IST 2006, {"vehicle"=>"V002", "evt"=>"arrival", "station"=>"T001"}]
Scenario has been loaded:  Sun Oct 29 13:36:54 IST 2006
[Sun Oct 29 13:37:14 IST 2006, {"vehicle"=>"V003", "evt"=>"departure", "station"=>"T001"}]
[Sun Oct 29 13:37:19 IST 2006, {"vehicle"=>"V002", "evt"=>"departure", "station"=>"T001"}]
[Sun Oct 29 13:37:29 IST 2006, {"vehicle"=>"V001", "evt"=>"arrival", "station"=>"T001"}]
[Sun Oct 29 13:37:47 IST 2006, {"vehicle"=>"V001", "evt"=>"departure", "station"=>"T001"}]
[Sun Oct 29 13:40:19 IST 2006, {"vehicle"=>"V003", "evt"=>"arrival", "station"=>"T002"}]
[Sun Oct 29 13:40:22 IST 2006, {"vehicle"=>"V002", "evt"=>"arrival", "station"=>"T002"}]
[Sun Oct 29 13:40:47 IST 2006, {"vehicle"=>"V001", "evt"=>"arrival", "station"=>"T002"}]
[Sun Oct 29 13:41:00 IST 2006, {"vehicle"=>"V003", "evt"=>"departure", "station"=>"T002"}]
[Sun Oct 29 13:41:05 IST 2006, {"vehicle"=>"V002", "evt"=>"departure", "station"=>"T002"}]
[Sun Oct 29 13:41:31 IST 2006, {"vehicle"=>"V001", "evt"=>"departure", "station"=>"T002"}]
[Sun Oct 29 13:42:53 IST 2006, {"vehicle"=>"V003", "evt"=>"arrival", "station"=>"T003"}]
[Sun Oct 29 13:42:55 IST 2006, {"vehicle"=>"V002", "evt"=>"arrival", "station"=>"T003"}]
[Sun Oct 29 13:43:21 IST 2006, {"vehicle"=>"V001", "evt"=>"arrival", "station"=>"T003"}]
[Sun Oct 29 13:43:36 IST 2006, {"vehicle"=>"V002", "evt"=>"departure", "station"=>"T003"}]
[Sun Oct 29 13:43:38 IST 2006, {"vehicle"=>"V003", "evt"=>"departure", "station"=>"T003"}]
[Sun Oct 29 13:44:06 IST 2006, {"vehicle"=>"V001", "evt"=>"departure", "station"=>"T003"}]
bus_event: vehicleV002evtarrivalstationT001 @13:37:04
bus_event: vehicleV003evtarrivalstationT001 @13:37:04
bus_event: vehicleV002evtarrivalstationT001 @13:37:14
bus_event: vehicleV003evtarrivalstationT001 @13:37:14
bus_event: vehicleV002evtdeparturestationT001 @13:37:14
bus_event: vehicleV003evtarrivalstationT001 @13:37:24
bus_event: vehicleV002evtdeparturestationT001 @13:37:24
bus_event: vehicleV003evtarrivalstationT001 @13:37:34
bus_event: vehicleV002evtdeparturestationT001 @13:37:34
bus_event: vehicleV003evtarrivalstationT001 @13:37:44
bus_event: vehicleV002evtdeparturestationT001 @13:37:44
bus_event: vehicleV003evtarrivalstationT001 @13:37:54
bus_event: vehicleV002evtdeparturestationT001 @13:37:54
bus_event: vehicleV002evtdeparturestationT001 @13:38:04

