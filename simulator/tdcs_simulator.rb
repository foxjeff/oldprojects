#!/usr/bin/env ruby -w

class String
	def extract_lups
		na=self.chomp.unpack("A3A5A*").to_s.split
		2.times {na.shift}
		na.each {|e| e.gsub!(/,/, '') }
		zs = []
		0.step(na.size-2,4) {|i| zs << na[i..i+3]}
		zs
	end
end

require 'simulator'
require '~/work/ITEWS/simulator/handle_ap.rb'

class Vehicle
	include Utility
	attr_accessor	:code
	attr_accessor	:license
	attr_accessor	:current_node
	attr_accessor	:previous_node
	attr_accessor	:next_node
	attr_accessor	:last_seen_time
	attr_accessor	:last_seq
	attr_accessor	:nodes

	attr_accessor	:powered_down

	Tu     = 1  # Tu = time interval of LUPs from IVTU before it gets LAK from TGATE. Typical value 3 seconds
	Tl     = 10 # time interval of LUPs from IVTU after it got LAK from TGATE. Typical value 10 seconds
	Npwdn  = 3  # typical value 3
	Mpwdn  = 3  # typical value 5
	Tassoc = 5  # association time typical value 5 seconds

	def initialize(code, license, nodes)
		Thread.abort_on_exception = true # *** take for production ***
		self.code = code
		self.license = license
		self.nodes = nodes
		self.current_node, self.previous_node, self.next_node = nil
	end
	def update(fcu_code, ivu_code, ivu_location_known, ivu_seq, ivu_timestamp)
		# need to add arrival/departure logic and distinguish btwn departure and power-down
		#		arrival = lups from a new/different TGate
		#		depart = absence of lups from a TGate, unless lups reappear ~30 sec later with a reset seq number
		#if ( (LUP-SEQNUM less than LAST-LUP-SEQNUM) 
		#	AND (LUP-TGATE-TIME - LAST-LUP-TGATE-TIME) IS NEARLY SAME AS (Tu*Npwdn + Tassoc+Tu*LUP-SEQNUM) )
		last_seen_delta = (Tu*Npwdn) + Tassoc + (Tu*ivu_seq.to_i)
		#When PIC detects ignition off it waits for Npwdn*Tl seconds, switches the relay to battery power, waits for (Mpwdn*Tu+Tassoc) seconds, switches the relay back and goes to power down mode.
		if current_node != fcu_code
			# arrival_event
			puts "#{code} has arrived at #{fcu_code}"
			#add_mac if @code =~ /V010/
		end
		#if ivu_location_known =~ /U/i
			#if ivu_seq < last_seq &&
					#ivu_timestamp - last_seen_time <= last_seen_delta
				#self.powered_down = true
			#elsif powered_down
				#self.powered_down = false
			#end
		#end
		#At regular intervals for each entry (LAST-LUP-IVTU, LAST-LUP-TGATE, LAST-LUP-TIMESTAMP) in the last_lup_table that is more than min X minutes old and vehicle is not powered down, generate a vehicle departure event with (LAST-LUP-IVTU, LAST-LUP-TGATE, LAST-LUP-TIMESTAMP)
		#see check_last_seen_time
		#puts "updating"
		if current_node && previous_node != current_node
			@previous_node = current_node
		end
		self.current_node = fcu_code unless current_node == fcu_code
		current_seq = 0
		if current_node
			@nodes.each do
				|n|
				if n['code'] == current_node
					current_seq = n['seq']
					break
				end
			end
			if current_seq < self.nodes.size
				@nodes.each do
					|n|
					if n['seq'] == current_seq + 1
						self.next_node = n['code']
						break
					end
				end
			else
				self.next_node = "finished"
			end
		end
			#current_seq = nodes.fetch(current_node).seq
				#self.next_node = (nodes.select {|k,v| v.seq == (current_seq + 1)})[0][1].code
				#puts "next node is: #{next_node}"
		@current_node = fcu_code unless current_node == fcu_code
		@last_seen_time = ivu_timestamp
	end
	def check_last_seen_time
		#puts "checking last_seen_time"
		now = Time.now.to_i
		if last_seen_time && (now - last_seen_time.to_i) > 5	#&& !powered_down #?? probably need to be minutes/TCF
			puts "#{code} has departed #{current_node}" if current_node
			#delete_mac if @code =~ /V010/i
			#departure event
			self.current_node = nil
			#puts "setting current_node to nil for #{code}"
		end
	end
	def to_s
		"vehicle code: #{code}, license: #{license}\n"
	end
end # class Vehicle
class Node
	attr_accessor	:code
	attr_accessor	:name
	attr_accessor	:tt
	attr_accessor	:seq

	def initialize(code, name, tt, seq)
		self.code = code
		self.name = name
		self.tt = tt
		self.seq = seq
	end
	def to_s
		"node seq: #{seq}, code: #{code}, name: #{name}, time-to-travel: #{tt}\n"
	end
end # class Node
class Acceptor
	require 'timeout'
	require 'yaml'
	require '/Users/jeff/work/ITEWS/simulator/scenarios'

	include Simulator
	include HighLine::SystemExtensions
	include Scenarios
	include Utility
	

	#all messages
	MESSAGE_MAIN_TYPE =	0 #string
	FCU_CODE					=	1 #string

	#for LUP aggregate
	#this descibes the LUP array returned from extract_lups
	#ivu_lups array, holds [IVU_CODE, location_known, seq, rabbit_timestam] for each IVU LUP
	IVU_CODE           = 0 #string, Vnnn
	IVU_LOCATION_KNOWN = 1 #string, U or L
	IVU_SEQ            = 2 #int 1-3 digits
	IVU_TIMESTAMP      = 3 #rabbit timestamp, large int

	#for TGate REG
	REG_PASSWORD			=	2 #string


	attr_reader		:server_thread
	attr_accessor :fcu_array
	attr_accessor	:shhhhhh
	attr_accessor	:control_session
	attr_accessor	:console_socket
	attr_accessor	:nodes
	attr_accessor	:vehicles
	attr_accessor	:show_vehicles
	attr_accessor	:scenario

	def initialize
		self.scenario = Scenario.new
		self.vehicles = {}
		self.nodes = {}
		self.show_vehicles = []
		@shhhhhh = true
		@server_thread = {}
		@server_thread.extend(MonitorMixin)
		Thread.abort_on_exception = true # *** take for production ***
		Thread.new { create_control_session }
	end
	def update_vehicles
		return if show_vehicles == nil
		vehicles_out = []
		show_vehicles.each do
			|v|
			if v.last_seen_time
				last_seen_time = v.last_seen_time.strftime("%H:%M")
			else
				last_seen_time = "---"
			end
			next_node = case v.next_node
			when nil: "---"
			when /t001/i: "TVM"
			when /t002/i: "KLM"
			when /t003/i: "KYM"
			when /t004/i: "ALP"
			when /t005/i: "EKM"
			else v.next_node
			end
			current_node = case v.current_node
			when nil: "en route"
			when /t001/i: "TVM"
			when /t002/i: "KLM"
			when /t003/i: "KYM"
			when /t004/i: "ALP"
			when /t005/i: "EKM"
			end
			previous_node = case v.previous_node
			when nil: "---"
			when /t001/i: "TVM"
			when /t002/i: "KLM"
			when /t003/i: "KYM"
			when /t004/i: "ALP"
			when /t005/i: "EKM"
			end
			if next_node =~ /finished/i
				current_node = "---"
			end
			vehicles_out << {
				:code           => v.code,
				:license        => v.license,
				:current_node   => current_node,
				:previous_node  => previous_node,
				:next_node      => next_node,
				:last_seen_time => last_seen_time}
		end
		File.open('vehicles.yaml', 'w') do |out| YAML.dump vehicles_out,out; end
	end
	def create_control_session
		puts "tdcs: in create_control_session"
		control_socket = TCPServer.new(CnC_IP, TDCS_CnC_PORT)
		self.control_session = control_socket.accept
		puts "tdcs: CnC has connected to control port. #{control_session}"
		Thread.new { handle_control }
	end
	def handle_control
		while command = control_session.readline.chomp
			case command
				when /connect_console/i
					self.console_socket = TCPSocket.new(CnC_IP, TDCS_CONSOLE_PORT)
					puts "Connected to CnC console listener. #{console_socket}"
				when /^scenario_file:/i
					self.show_vehicles = []
					scenario_file = command
					scenario_file["scenario_file:"] = ""
					scenario.load_routes "/Users/jeff/work/ITEWS/simulator/#{scenario_file}"
					scenario.routes.each do
						|r|
						r.current_node=1  # necessary due to some YAML weirdness
						r.vehicles.each do
							|v|
							new_vehicle = Vehicle.new(v['code'], v['lic'], r.nodes)
							self.show_vehicles << new_vehicle
							self.vehicles[v['code']] = new_vehicle
						end
						# needs to be added to vehicles route name #self.name << r.name
					end
					puts "in tdcs, loading scenario_file"
					p vehicles
					update_vehicles
					#p nodes
					#p name
				when /^route_info:/i
					route_info_ = command
					route_info_["route_info:"] = ""
					nodes_, vehicles_, name = route_info_.split("|")
					(eval vehicles_).each do
						|v|
						new_vehicle = Vehicle.new(v['code'], v['lic'])
						self.show_vehicles << new_vehicle
						self.vehicles[v['code']] = new_vehicle
					end
					p vehicles
					update_vehicles
					(eval nodes_).each do
						|n|
						self.nodes[n['code']] = Node.new(n['code'], n['name'], n['tt'], n['seq'])
					end
					p nodes
				when /quit/i
					puts "tdcs: CnC says to go away now..."
					begin
						Timeout::timeout(5) do
							puts "going away now...waiting for all connections to drop"
							@server_thread.each {|s, thread| thread.join}
						end
					rescue Timeout::Error
						puts "timed out waiting for TDCS connections to drop, exiiting now"
					ensure
						Thread.list.each {|th| th.exit if th.exit==th}
						#exit(0)
					end
				else
					puts "CnC: #{command}"
				end
			sleep 1.5
		end
	end
	def accept
		puts "hello world, now accepting connections at ip: #{TDCS_IP} on port: #{TDCS_PORT}", "it's now #{Time.now}"
		#delete_mac
		Thread.new { check_vehicles }

		begin
			#Signal.trap("INT") do
				#end
			server = TCPServer.new(TDCS_IP, TDCS_PORT) 
			while (session = server.accept) 
				@server_thread.synchronize do
					@server_thread[session] = Thread.new { handle_session(session) } 
				end
				puts("starting new session: #{session}", "there are currently #{@server_thread.size} sessions") unless shhhhhh
			end 
		rescue Timeout::Error
			puts "timed out waiting for TGate connections to drop, exiiting now"
			exit(0)
		rescue
			puts "Error: #{$!}"
		ensure
			server.close
		end
	end
	def check_vehicles
		loop do
			vehicles.each_value do
				|vehicle|
				vehicle.check_last_seen_time
			end
			update_vehicles
			sleep 5
		end
	end

	def handle_command_input
		Thread.new { accept }	#{ handle_command_input }
		Thread.new { check_vehicles }
		while ( command = get_character )
			case command.chr
				when /q/
					begin
						Timeout::timeout(5) do
							puts "going away now...waiting for all connections to drop"
							@server_thread.each {|s, thread| thread.join}
							exit(0)
						end
					rescue Timeout::Error
						puts "timed out waiting for TDCS connections to drop, exiiting now"
						exit(0)
					end
				when /\?/
					puts "there are currently #{@server_thread.size} sessions", @server_thread.inspect
				when /s/
					@shhhhhh = shhhhhh ? false : true
					puts shhhhhh ? "shhhhhh" : "okay, here it comes"
				else
					puts "TDCS says hello #{'I am being quiet' if shhhhhh}"
			end
		end
	end

	def handle_session(session)
		begin
			while ( request = session.readline )
				puts "Request: #{request}" unless shhhhhh
				#process request here: LUP gets LAK; REG gets LNM and TUP
				msg_array = request.unpack("A*").to_s.chomp.split
				received_timestamp = Time.now.to_i - RABBIT_EPOCH_DELTA
				case msg_array[MESSAGE_MAIN_TYPE]
					when /REG/i 
						fcu_code = msg_array[FCU_CODE]
						reg_pswd = msg_array[REG_PASSWORD]
						fcu_name = lookup_fcu_code(fcu_code, reg_pswd)
						if ! fcu_name
							puts "bad fcu_code #{fcu_code} or reg_password #{reg_pswd} from tgate"
							next
						end
						session.puts "LNM #{fcu_name}"
						session.puts "TUP #{received_timestamp}"
					when /LUP/i 
						lups = request.extract_lups
						#p "lups #{lups.inspect}"
						process_lups(msg_array[MESSAGE_MAIN_TYPE], msg_array[FCU_CODE], received_timestamp, lups)
						db=DBI.connect('DBI:Mysql:simulator_development','root','')
						db.do("UPDATE fcus SET last_message_timestamp = #{received_timestamp} WHERE fcu_code = ?", msg_array[FCU_CODE])
						db.disconnect
						#empty LAK for now
						session.puts "LAK"
					else
						puts "bad message from tgate: #{msg_array}"
				end
			end #while 
			@server_thread.synchronize do
				@server_thread.reject! {|s,t| t == Thread.current}
			end
			session.close 
			puts "session dropped, there are now #{@server_thread.size} sessions" unless shhhhhh
			Thread.exit
		rescue Exception => e
			#puts "Error in handle_session: #{e}" unless shhhhhh
			@server_thread.synchronize do
				@server_thread.reject! {|s,t| t == Thread.current}
			end
			session.close 
			puts "session dropped, there are now #{@server_thread.size} sessions" unless shhhhhh
		end #begin 
	end #handle_session 

	def process_lups(main_type, fcu_code, received_timestamp, lups)
		fu_type = "TGate"
		db=DBI.connect('DBI:Mysql:simulator_development','root','')
		row = db.select_one(%q(
			SELECT id
			FROM message_types
			WHERE main_type = ?
				AND fu_type = ?
			), main_type, fu_type)
		if ! row
			puts "bad #{fu_type} from #{main_type} at #{received_timestamp}"
			db.disconnect
			return
		end
		message_type_id = row [0];
		row = db.select_one(%q(
			SELECT id
			FROM fcus
			WHERE fcu_code = ?
			), fcu_code)
		if ! row
			puts "bad #{fcu_code} from #{main_type} at #{received_timestamp}"
			db.disconnect
			return
		end
		fcu_id = row[0]
		row = db.do(%q(
			INSERT INTO telematics_messages
				(received_timestamp, fcu_id, message_type_id)
				VALUES
				(?,?,?)
			), received_timestamp, fcu_id, message_type_id)
		# need to add arrival/departure logic and distinguish btwn departure and power-down
		#		arrival = lups from a new/different TGate
		#		depart = absence of lups from a TGate, unless lups reappear ~30 sec later with a reset seq number
		lups.each do
			|lup|
			ivu_code           = lup[IVU_CODE]
			ivu_location_known = lup[IVU_LOCATION_KNOWN]
			ivu_seq            = lup[IVU_SEQ]
			ivu_timestamp      = lup[IVU_TIMESTAMP]
			vehicle = vehicles.fetch(ivu_code)
			vehicle.update(fcu_code, ivu_code, ivu_location_known, ivu_seq, Time.at(ivu_timestamp.to_i+RABBIT_EPOCH_DELTA))
			#p vehicle

			fu_type = "IVTU"
			main_type = "LUP"
			row = db.select_one(%q(
				SELECT id
				FROM message_types
				WHERE main_type = ?
					AND fu_type = ?
				), main_type, fu_type)
			if ! row
				puts "bad #{fu_type} from #{main_type} at #{received_timestamp}"
				db.disconnect
				return
			end
			message_type_id = row[0]
			row = db.select_one(%q(
				SELECT id
				FROM ivus
				WHERE ivu_code = ?
				), ivu_code)
			if ! row
				puts "bad #{ivu_code} from #{main_type} at #{received_timestamp}"
				db.disconnect
				return
			end
			ivu_id = row[0]
			row = db.do(%q(
				INSERT INTO telematics_messages
					(received_timestamp, ivu_id, message_type_id, message_timestamp)
					VALUES
					(?,?,?,?)
				), received_timestamp, ivu_id, message_type_id, ivu_timestamp)
		end
		db.disconnect
	end

	def lookup_fcu_code(fcu_code, reg_pswd)
		db=DBI.connect('DBI:Mysql:simulator_development','root','')
		row = db.select_one(%q(
			SELECT fcus.fcu_code, fcus.reg_password, nodes.short_name
			FROM fcus, nodes
			WHERE fcus.id = nodes.fcu_id
				AND UPPER(fcu_code) = ?
				AND UPPER(reg_password) = ?
				), fcu_code, reg_pswd)
		if ! row
			nil
		else
			row[2]
		end
	rescue DatabaseError => e
		puts "error: #{e}"
	ensure
		db.disconnect
	end #lookup_fcu_code 

end # class Acceptor 


a = Acceptor.new
#a.handle_command_input
a.accept


	#def process_route_info(nodes_,vehicles_,name)
		#self.route_info = []
		#vehicle = {}
		#node ={}
		#vehicles_.each do
			#|v|
			#vehicle[v['code']] = [v['lic']]
		#end
		#self.route_info << vehicle
		#nodes_.each do
			#|n|
			#node[n['code']] = [n['name'], n['tt']]
		#end
		#self.route_info << node
		#self.route_info << name
		#p route_info
	#end
