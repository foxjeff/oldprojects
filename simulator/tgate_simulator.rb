#!/usr/bin/env ruby -w

require 'simulator'
require 'handle_ap.rb'

	class TGate_simulator
		include Socket::Constants
		include HighLine::SystemExtensions
		include Simulator
		include Utility

		attr_accessor :udp_socket
		attr_accessor :server_threads
		attr_reader		:tgates
		attr_accessor	:network_down
		attr_accessor :console_socket
		attr_accessor :control_session
		attr_accessor	:pairs

		def initialize
			Thread.abort_on_exception = true # *** take for production ***
			#do this in a thread as it blocks waiting for cnc to connect
			Thread.new { create_control_session }

			# startup our TGates according to the rows in the fcus table
			@tgates = {}
			Thread.new { startup_tgates }
			self.pairs = {}

			# this gets us our socket
			@udp_socket = UDPSocket.open
			 #==> <UDPSocket:0x71e5ec>

			# this is the one and only udp socket for recv all IVTU LUPS
			# the handler method dispatches to proper tgate
			@udp_socket.bind(TGATE_IVTU_IP, TGATE_PORT) 
			 #==> 0

			@network_down = false

			@server_threads = {}

			@server_threads['itvu_tgate'] = Thread.new { start_itvu_comm }
			@server_threads['tgate_tdcs'] = Thread.new { start_tdcs_comm }

			#delete_mac
			loop do
				sleep 0.33
			end
			#and finally, do this till is time to go
			#handle_commands

		end #initialize 

		def handle_control
			while command = control_session.readline.chomp
				case command
					when /connect_console/i
						self.console_socket = TCPSocket.new(CnC_IP, TGATE_CONSOLE_PORT)
						puts "Connected to CnC console listener. #{console_socket}"
					when /^pairs:/
						pairs_str = command
						pairs_str["pairs:"] = ""
						new_pairs = eval pairs_str
						#process pairs
						self.pairs = pairs.merge(new_pairs)
						if self.pairs.has_key?("V010")
							add_mac
						end
						p pairs
					when /network_down/i
						puts "taking network offline for tgate simulator"
						@network_down = true
					when /network_up/i
						puts "putting network online for tgate simulator"
						@network_down = false
					when /tgate_status/i
						@tgates.each_value do |tgate| 
							console_socket.puts tgate.code
							tgate.ivu_lups.each {|v| console_socket.puts "#{tgate.code}, #{v.inspect}\n"}
						end

					when /quit/i
						puts "tgate: CnC says to go away now..."
						#@server_threads.each_value {|thread| thread.terminate}
						Thread.list.each {|th| th.exit if th.exit==th}
						Kernel::exit(true)
					else
						puts "CnC: #{command}"
					end
				sleep 0.5
			end
		end
		def create_control_session
			puts "tgate: create server for cnc"
			control_socket = TCPServer.new(CnC_IP, TGATE_CnC_PORT)
			puts "tgate: waiting for cnc to connect to control"
			self.control_session = control_socket.accept
			puts "tgate: CnC has connected to control port. #{control_session}"
			Thread.new { handle_control }
			#while msg = control_session.recvfrom(MAX_RECEIVE_SIZE) #readline.chomp
				#puts msg unless msg
			#end
		end

		def startup_tgates
			# get fcus rows from the simulator db
			# for each fcu_code of type=TGate, start a tgate instance
			begin
				db=DBI.connect('DBI:Mysql:simulator_development','root','')
				rows = db.select_all(%q(
											SELECT fcus.fcu_code, fcus.reg_password
											FROM fcus
											WHERE UPPER(fcu_type) = "TGATE"
											))
				db.disconnect
				tdcs_socket = TCPSocket.new(TDCS_IP, TGATE_PORT)
				rows.each do |row| 
					code = row[0]
					pswd = row[1]
					#keep a hash of tgate objects around
					@tgates[code] = TGate.new(code, pswd, tdcs_socket)
				end
			rescue DBI::DatabaseError => e
				puts "database error: #{e.err}: #{e.errstr}"
			rescue Exception => e
				puts "no TDCS found, will retry in 10sec; #{e}"
				sleep 10
				retry
			ensure
				tdcs_socket.close if tdcs_socket
				db.disconnect if db.connected?
			end
		end

		def handle_commands
			puts "ready for commands" 
			while ( command = get_character )
				case command.chr
					when /q/
						puts "going away now..."
						@server_threads.each {|s, th| th.exit if th.exit==th}
						#Kernel::exit(true)
					when /\?/
						@tgates.each_value do |tgate| 
							print tgate.code
							tgate.ivu_lups.each {|v| print "#{tgate.code}, #{v.inspect}\n"}
							print "\n"
						end
						#puts "stuff is happening" #"there are currently #{@server_threads.size} sessions", @server_threads.inspect
					when /l/
						ivu_code = ask("IVU_CODE? ") {|c| c.validate = /V\d\d\d/}
						puts tgate_lookup(ivu_code)
					when /d/
						puts "taking network offline for tgate simulator"
						@network_down = true
					when /u/
						puts "putting network online for tgate simulator"
						@network_down = false
					when /s/
						console_socket.puts "hi there"
					when /t/
						puts @tgates
					else
						puts "hello from tgate simulator"
				end
			end
		end

		def start_tdcs_comm
			# connect and wait for a response, then go back to sleep
			#
			begin
				tdcs_socket = TCPSocket.new(TDCS_IP, TGATE_PORT)
				loop do
					raise Errno::ENETDOWN if network_down
					tdcs_lup_message = nil
					@tgates.each_value do 
						|tgate| # for each tgate
						tdcs_lup_message = "LUP #{tgate.code}" if ! tdcs_lup_message
						first_lup = true
						tgate.ivu_lups.each do
							|lup|
							if first_lup
								tdcs_lup_message += " "
								first_lup = false
							else
								tdcs_lup_message += ", " unless first_lup
							end
							# *** add lf & seq to tdcs_lup_message ***
							#ivu_lups array, holds [IVU_CODE, location_known, seq, rabbit_timestam] for each IVU LUP
							tdcs_lup_message += "#{lup[0]} #{lup[1]} #{lup[2]} #{lup[3]}"
							#p tdcs_lup_message
						end #ivu_lups.each
						#p "sending #{tdcs_lup_message}"
						tdcs_socket.puts tdcs_lup_message
						#p tdcs_lup_message
						#p "waiting for response"
						tdcs_response = tdcs_socket.readline.chomp
						#p "tdcs said: #{tdcs_response}","clearing LUP aggregate now"
						tgate.ivu_lups.synchronize do
							tgate.ivu_lups.clear
						end
						tdcs_lup_message = nil
					end #@tgates.each_value
					#puts "sleeping now for 10..."
					sleep 2	#10
				end
			rescue Errno::ENETDOWN => e
				puts "TDCS Network is unavailable => #{e}"
				tdcs_socket.close if tdcs_socket
				while network_down
					sleep 5
				end
				puts "TDCS Network is reacquired"
				retry
			rescue Exception => e #Errno::ECONNREFUSED	#Errno::Connectionreset (lookup err code)
				#puts "no TDCS found, will retry in 10sec; #{e}"
				sleep 10
				retry
			ensure
				tdcs_socket.close if tdcs_socket
			end
		end

		def start_itvu_comm
			while true
				#add command interrupt behavior
				msg,sender = @udp_socket.recvfrom(MAX_RECEIVE_SIZE)
				 #==> ["LUP V001 U 7 0 0 0\n", ["AF_INET", 49472, "tgate", "10.1.254.254"]
				# process the LUP
				#p msg.unpack("A*").to_s.chomp
				msg_array = msg.unpack("A*").to_s.chomp.split
				#p msg_array
				 #==> ["LUP", "V001", "U", "7", "0", "0", "0"] a nice array via some ruby magic
				 #so locknown is msg_array[LOCATION_KNOWN] for instance
				#puts "IVU ##{msg_array[IVU_CODE]}, sent #{msg_array[MESSAGE_MAIN_TYPE]} from port #{sender[SENDER_PORT]}"
				#
				#tgate_lookup finds the tgate instance for this vehicle, then we send it a dispatch message to handle comm
				tgate = nil
				if tgate = tgate_lookup(msg_array[IVU_CODE])
					#puts "TGate #{msg_array[IVU_CODE]} is listening for IVTU traffic."
					Thread.new {tgate.dispatch(
													msg_array[IVU_CODE],
													msg_array[LOCATION_KNOWN],
													msg_array[SEQUENCE_NUMBER],
													sender[SENDER_IP],
													sender[SENDER_PORT]
													)} 
				#else
					#sock=UDPSocket.new
					#puts sock.send("No LAK for you", 0, sender[SENDER_IP], sender[SENDER_PORT])
					#sock.close
				end
			end
		end

		def tgate_lookup(ivu_code)
			# station-ivtu-pairs:
			# [{ivtu_code => tgate_code},
			#  {itvtu_code => tgate_code}]
			#p pairs, ivu_code
			tgate_code = pairs.fetch(ivu_code, "T000")
			return nil if tgate_code == "T000"
			return @tgates[tgate_code]
			#
			#given the vehicle's ivu_code, get fcu_code for this vehicles expected node
			#SELECT my.vehicle_id FROM ivus WHERE ivu_code = ivu_code
			#SELECT my.t.route_id, my.ct.cuurent_node_id FROM trips t, current_trips ct WHERE t.id = ct.trip_id AND t.vehicle_id = my.vehicle_id
			#SELECT route_id, current_node_id, ct.trip_id FROM trips t, current_trips ct WHERE t.id = ct.trip_id  and t.vehicle_id = (SELECT vehicle_id FROM ivus WHERE ivu_code = 'V004');
			#e.g. my.vehicle_code = 4 for IVU V004
			#e.g. my.t.trip_id = 4, route_id = 4, current_node = 8 for vehicle_id = 4 for the current_trip
			#e.g. my.t.trip_id = 2  route_id = 4, current_node = 0 for vehicle_id = 4 for differnt current_trip
			#if current_node_id == 0 get start_node_id of MIN(edge_order) for route_id
			#SELECT start_node_id, short_name FROM route_edges re, nodes n WHERE re.edge_order = 1 and re.route_id = 4 AND re.start_node_id = n.id ;
			#else get end_node_id from route_edges for route_id where current_node_id == start_node_id
			#SELECT end_node_id FROM route_edges re, nodes n WHERE re.start_node_id = 8 AND re.end_node_id = n.id ;
			#if node_id nil then current_node_id is last_node
			#begin
			#db=DBI.connect('DBI:Mysql:simulator_development','root','')
			#row = db.select_one(%q(
								#SELECT t.route_id, ct.current_node_id, ct.trip_id FROM trips t, current_trips ct
								#WHERE t.id = ct.trip_id AND t.vehicle_id = 
													#(SELECT vehicle_id FROM ivus WHERE ivu_code = ?) ), ivu_code)
			#if !row
				#db.disconnect
				#puts "tgate_lookup failed; there is no current trip for the vehicle with ivu_code: #{ivu_code}"
				#return
			#end
			#route_id = row[0]
			#current_node_id = row[1]
			#trip_id = row[2]
			#puts "trip_id: #{trip_id}, current_node_id: #{current_node_id}, route_id: #{route_id}"
			#if current_node_id == 0 #	beginning of trip
				#row = db.select_one(%q(
								#SELECT start_node_id, short_name 
								#FROM route_edges AS re, nodes AS n 
								#WHERE re.edge_order = 1 AND re.route_id = ? AND re.start_node_id = n.id
								#), route_id)
			#else
				#row = db.select_one(%q(
								#SELECT end_node_id, short_name 
								#FROM route_edges AS re, nodes AS n 
								#WHERE re.start_node_id = ? AND re.route_id = ? AND re.end_node_id = n.id
								#), current_node_id, route_id)
			#end
			#if !row
				#tgate_node_id = current_node_id	#current_node_id is an end_node, shouldn't happen
			#else
				#tgate_node_id = row[0]
				#puts "got: #{row[0]} for node_id and #{row[1]}"
			#end
			#row = db.select_one(%q(
								#SELECT fcu_code, short_name 
								#FROM fcus, nodes 
								#WHERE nodes.id = ? AND fcu_id = fcus.id
								#), tgate_node_id)
			#rescue DBI::DatabaseError => e
				#puts "database error: #{e.err}: #{e.errstr}"
			#ensure
				#db.disconnect if db.connected?
			#end
			#fcu_code = "T999" #unknown
			#fcu_code = row[0] if row
			#puts "fcu_code: #{fcu_code}, #{row[1]}"
			#p @tgates[fcu_code]
			#@tgates[fcu_code]
			#[fcu_code, row[1]]
		end
	end # class TGate_simulator

	class TGate # < FCU
		include Simulator

		attr_accessor :ivu_lups
		attr_reader		:name
		attr_reader		:code
		attr_reader		:reg_password
		attr_accessor :tdcs_time

		def initialize(code, reg_password, tdcs_socket)
			Thread.abort_on_exception = true # *** take for production ***
			@code = code
			@reg_password = reg_password
			@tdcs_time = 0
			#ivu_lups array, holds [IVU_CODE, location_known, seq, rabbit_timestam] for each IVU LUP
			#needs to be sent and cleared every n seconds; lets start with 10 sec.
			@ivu_lups = []
			@ivu_lups.extend(MonitorMixin)
			send_REG(tdcs_socket)
			[@code,@reg_password]
		end

		def send_REG(tdcs_socket)
			reg_message = "REG #{@code} #{@reg_password}\n"
			tdcs_socket.puts reg_message
			#handle the double recv
			2.times do
				tdcs_response = tdcs_socket.readline.chomp
				msg_array = tdcs_response.unpack("A*").to_s.split
				case msg_array[MESSAGE_MAIN_TYPE]
					when "TUP":	@tdcs_time = msg_array[1]
					when "LNM":	@name = msg_array[1]
				else
					puts "bad message from tdcs: #{msg_array}"
					@name = @code
					@tdcs_time = 0
				end
			end
			puts "TGate @#{@name} is online @#{@tdcs_time}"
		end

		def dispatch(ivu_code, location_known, seq, ivu_ip, ivu_port)
			#handle comm with this vehicle/ivu
			#this will certainly be run in a thread
			#
			#		spawn a thread or not to handle LAK and subsequent LUPs
			#		as well as TDCS aggregate LUP
			#puts ivu_code, location_known, ivu_ip, ivu_port
			timestamp = Time.now
			rabbit_timestamp = timestamp.to_i - RABBIT_EPOCH_DELTA
			log_message_time = timestamp.strftime("%X")

			if location_known =~ /[Uu]/ 
				# what station is that??
				lak_message = "LAK #{code} #{name}\n"
				udp_socket = UDPSocket.open
				#make sure clients, ivtu_sims, do not connect or bind, but use ad-hoc
				udp_socket.send(lak_message, 0, ivu_ip, ivu_port)
				 #==> 16 (bytes sent)
				udp_socket.close
			#else: no LAK for locationknow = L
			end
			#archive IVU LUP?
			#*** this isn't done yet ***
			#ivu_lups array, holds [IVU_CODE, rabbit_timestam] for each IVU LUP
			#first we delete from aggregate, then replace with the more recent lup
			# *** add seq to ivu_lups ***
			@ivu_lups.synchronize do
				if existing_lup = @ivu_lups.assoc(ivu_code) # if there is already a lup entry for this ivu_code
					if location_known =~ /L/i && existing_lup[2] =~ /U/i
						location_known = "U" # don't change existing "U" to "L" as it may be a power-down situation
					end
				end
				@ivu_lups.delete_if {|lup| lup[0] == ivu_code} 
				@ivu_lups << [ivu_code, location_known, seq, rabbit_timestamp]
			end
		end
	end # class TGate
#end

a=TGate_simulator.new
#a.handle_commands
#a.handle_control

#use COALESCE to get null's to something meaningful
#trip instantiation
#	set timestamp to time of instantiation and current_node_id = 0
#
#need a "next node" function
#
#gets last node for a route:
#row = db.select_one(%q(
#SELECT re.end_node_id, description 
#FROM nodes, route_edges re
#WHERE re.edge_order = 
#   (SELECT MAX(re.edge_order) 
#    FROM route_edges re 
#    WHERE re.route_id = 4) 
#      AND re.route_id = 4 
#      AND re.end_node_id = nodes.id))
#select re.end_node_id, description from nodes, route_edges re where re.edge_order = (select max(re.edge_order) from route_edges re where re.route_id = 4) and re.route_id = 4 and re.end_node_id = nodes.id;
#+-------------+--------------------------------+
#| end_node_id | description                    |
#+-------------+--------------------------------+
#|           4 | Trivandrum.Central Bus Station | 
#+-------------+--------------------------------+
#
#some dbi code
#ci=st.column_info
#ci.each {|h| h.each {|k,v| puts "#{k} => #{v}" if k == 'name'}}
#
#st=db.execute("SELECT * FROM current_trips")
#key and value are backwards...weird
#ENETDOWN    st.each {|h| h.each_with_name {|v,k| puts "#{k} => #{v}" }}
#Errno::ENETUNREACH, Errno::ENETRESET, Errno::ECONNABORTED, Errno::ECONNRESET, Errno::ENOBUFS, Errno::EISCONN, Errno::ENOTCONN, Errno::ESHUTDOWN, Errno::ETOOMANYREFS, Errno::ETIMEDOUT, Errno::ECONNREFUSED
