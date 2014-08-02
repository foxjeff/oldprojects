#!/usr/bin/env ruby -w
#

module Simulator

	require 'socket'
	require 'monitor'
	require 'rubygems'
	require 'highline/import'
	require 'dbi'

	#used to convert to/from rabbit timestamps
	#actual tgates have rabbits that use 1980,1,1 as the epoch
	#we will subtract this delta from our timestamps to simulate this
	RABBIT_EPOCH_DELTA= Time.utc(1980,1,1).to_i
	# tgate is 10.1.254.254 (don't forget to: sudo ifconfig en0 alias 10.1.254.254 netmask 255.255.0.0) 
	TGATE_IVTU_IP			= 'tgate'
	TGATE_PORT				= 9090

	MAX_RECEIVE_SIZE	= 1024
	# sender for a simulated ivtu is a tgate; these are positions in the sender[]
	SENDER_IP					= 3
	SENDER_PORT				= 1

	#for IVTU LUP, msg_array
	MESSAGE_MAIN_TYPE =	0 #string
	IVU_CODE					=	1 #string
	LOCATION_KNOWN		=	2 # "L for known and "U" for unknown
	SEQUENCE_NUMBER		= 3 #int
	RSSI							= 4 #int
	NOISE							= 5 #int
	QUALITY						= 6 #int

	TDCS_IP						= '127.0.0.1'		# 192.168.0.233
	TDCS_PORT					= 9090

	CnC_IP						= '127.0.0.1'
	#sims server these ports for CnC (Command aNd Control) connections
	TGATE_CnC_PORT		= 10001
	TDCS_CnC_PORT			= 10002
	IVTU_CnC_PORT			= 10003

	#sims server these ports for output to CnC
	TGATE_CONSOLE_PORT= 11001
	TDCS_CONSOLE_PORT	= 11002
	IVTU_CONSOLE_PORT = 11003

	#these prob. arent needed: ports CnC connects to for console 
	CnC_TGATE_PORT		= 11011
	Cnc_TDCS_PORT			= 11012
	CnC_IVTU_PORT			= 11013

	class IVTU_simulator
		include Simulator
		include HighLine::SystemExtensions

		attr_accessor	:ivtus
		attr_accessor :console_socket
		attr_accessor :control_session

		def initialize
			at_exit { puts "ivtu: CnC says to go away now..." }
			#create ivtu's for every ivtu in the ivus table
			#ivtu's are initially dormant
			#when awakened, ivtu will start sending LUP <ivu_code> U\n
			#will continue sending this until LAK is received with tgate name
			#then will send LUP <ivu_code> L\n every ten seconds
			#ivtu's use adhoc udp sending protocol, never bind or connect
			#
			#will need ability to tell an ivtu to shutdown and restart after some given time period

			@ivtus = {}
			#create_ivtu
			#@ivtus.each {|ivtu| puts ivtu}
			#send_lups
			Thread.abort_on_exception = true # *** take for production ***
			Thread.new { create_control_session }
			loop do
				sleep 0.33
			end
			#Thread.new(handle_commands)
			#handle_commands
		end
		def create_control_session
			puts "ivtu: create server for cnc"
			control_socket = TCPServer.new(CnC_IP, IVTU_CnC_PORT)
			puts "ivtu: waiting for cnc to connect to control"
			self.control_session = control_socket.accept
			puts "ivtu: CnC has connected to control port. #{control_session}"
			Thread.new { handle_control }
		end
		def handle_control
			while command = control_session.readline.chomp
				case command
					when /connect_console/i
						self.console_socket = TCPSocket.new(CnC_IP, IVTU_CONSOLE_PORT)
						puts "Connected to CnC console listener. #{console_socket}"
					when /create_ivtu:/i
						ivtu = command
						ivtu["create_ivtu:"] = ""
						code,vehicle = ivtu.split(",")
						create_ivtu(code,vehicle)
					when /^startup:/
						ivtu = command
						ivtu["startup:"] = ""
						#puts "starting up #{ivtu}"
						Thread.new {ivtus[ivtu].startup}
					when /^shutdown:/
						ivtu = command
						ivtu["shutdown:"] = ""
						#puts "shutting down #{ivtu}"
						#Thread.new {ivtus[ivtu].shutdown}
						ivtus[ivtu].shutdown

					when /quit/i
						Thread.list.each {|th| th.exit if th.exit==th}
						raise "Time to exit"
						#Kernel::exit(true)
					else
						puts "CnC: #{command}"
					end
				sleep 1 #1.5
			end
		end

		def handle_commands
			puts "ready for commands" 
			while ( command = get_character )
				case command.chr
					when /f/
						#puts "asking active IVTUs to shutdown"
						#active ivtus?
						#show list of started ivtus
						started_ivtus = []
						@ivtus.each {|code,ivtu| started_ivtus << code if ivtu.started?}
						ivtus   = ask( "Shutdown which IVTUS: #{started_ivtus.join(", ")} (comma separated list)\n",
                             lambda { |str| str.split(/,\s*/) } )
						puts ivtus
						#choose do 
							#|menu|
							#menu.prompt = "Shutdown which IVTUs?: "
							#menu.choice(:V001) {say "wtg"}
							#menu.choices(:thing2, :nothing) {say "hmmm"}
						#end
						ivtus.each {|ivtu| @ivtus[ivtu].shutdown}
					when /d/
						puts "asking active IVTUs to power_down"
						@ivtus.each_value {|ivtu| ivtu.power_down}
					when /u/
						puts "asking active IVTUs to power_up"
						@ivtus.each_value {|ivtu| ivtu.power_up}
					when /q/
						puts "IVTU Simulator is shutting down..."
						Kernel::exit(true)
					when /\?/
						@ivtus.each_value {|ivtu| p ivtu}
					else
						puts "IVTU Simulator says hello"
				end
			end
		end
		def create_ivtu(code, license)
			@ivtus[code] = IVTU.new(code, license)
			p @ivtus[code]
			# get ivtus rows from the simulator db
			# for each ivu_code of type=ivtu, create an ivtu instance
			#begin
				#db=DBI.connect('DBI:Mysql:simulator_development','root','')
				#rows = db.select_all(%q(
											#SELECT ivus.ivu_code, ivus.vehicle_id, v.license_number, v.description, v.vehicle_type
											#FROM ivus, vehicles AS v
											#WHERE UPPER(ivu_type) = "IVTU"
												#AND ivus.vehicle_id = v.id
											#))
				#db.disconnect
				#rows.each do |row| 
					#code = row[0]
					#vehi = row[1]
					#keep a hash of ivtu objects around
					#@ivtus[code] = IVTU.new(code, vehi, row[2], row[3], row[4])
				#end
			#rescue DBI::DatabaseError => e
				#puts "database error in create ivtus: #{e.err}: #{e.errstr}"
			#ensure
				#db.disconnect if db.connected?
			#end
		end
		def send_lups
			@ivtus.each_value do
				|ivtu|
				Thread.new {ivtu.startup} if ivtu_has_trip?(ivtu.vehicle_id)
			end
		end
		def ivtu_has_trip?(vehicle_id)
			db=DBI.connect('DBI:Mysql:simulator_development','root','')
			row = db.select_one(%q(
										SELECT current_trips.trip_id
										FROM trips, current_trips
										WHERE trips.vehicle_id = ?
											AND trips.id = current_trips.trip_id
										), vehicle_id)
			db.disconnect
			if row: true; else false; end
		end

	end #IVTU_simulator

	class IVTU
		require 'timeout'

		attr_accessor :code
		attr_accessor :vehicle_id
		attr_accessor :locattion_known
		attr_accessor :tgate_name
		attr_accessor	:license_number, :description, :vehicle_type
		attr_accessor	:seq
		attr_accessor	:thread

		def initialize(code, license)	#vehicle_id, *more)
			@code = code
			@license_number = license
			#@vehicle_id = vehicle_id
			reset_location_known
			#@license_number, @description, @vehicle_type = more
			#[@code, @vehicle_id]
		end
		def startup
			@power_down = false
			@shutdown = false
			@started = true
			puts "#{code} has arrived."
			start_lup_process if ! location_known?
		end
		def started?
			@started
		end
		def power_down?
			@power_down
		end
		def power_down
			reset_location_known
			@power_down = true
			#do special power_down lup (nyi)
		end
		def power_up
			@power_down = false
			@shutdown = false
			@started = true
			puts "#{code} is powering-up."
			start_lup_process if location_known?
		end
		def shutdown
			@shutdown = true
			@started = false
			@power_down = true
			reset_location_known
			puts "#{code} is moving."
			@thread.exit
		end
		def shutdown?
			@shutdown
		end
		def move(sometime)
			shutdown
			sleep sometime
			startup
		end
		def reset_location_known
			@location_known = "U"
			@seq = 1
			@tgate_name = ""
		end
		def location_known?
			if @location_known == "L"
				true
			else
				false
			end
		end
		def start_lup_process
			udp_socket = UDPSocket.open
			if location_known?
				lup_message = "LUP #{@code} L #{@seq}"
			else
				lup_message = "LUP #{@code} U #{@seq}"
			end
			@seq += 1
			#puts lup_message
			
			tgate_response = ""
			begin 
				Timeout::timeout(5) do
					#make sure clients, ivtu_sims, do not connect or bind, but use ad-hoc
					udp_socket.send(lup_message, 0, TGATE_IVTU_IP, TGATE_PORT)
					puts "#{@code} is waiting for response from TGate" 
					tgate_response, sender = udp_socket.recvfrom(100) if !location_known?
					puts "#{@code}, response received: #{tgate_response.chomp}"
				end 
			rescue Timeout::Error 
				puts "#{@code}, retrying TGate...." 
				retry
			end 
			if have_location?(tgate_response)
				@location_known = "L"
				puts "#{@code}, starting LUP L sequence"
				@thread = Thread.new {send_lups_till_shutdown(udp_socket)}
			else
				udp_socket.close
			end
		end
		def send_lups_till_shutdown(udp_socket)
			@started = true
			begin
				loop do
					break if shutdown?
					#make sure clients, ivtu_sims, do not connect or bind, but use ad-hoc
					lup_message = "LUP #{@code} L #{@seq}"
					udp_socket.send(lup_message, 0, TGATE_IVTU_IP, TGATE_PORT) unless power_down?
					@seq += 1
					sleep 2	#10
				end 
			rescue Exception => e
				puts "error in IVTU LUP loop: #{e}\nGoing away."
			ensure
				#puts "#{code} has shut down"
				udp_socket.close
			end
		end
		def have_location?(tgate_response)
			msg = tgate_response.unpack("A*").to_s.chomp.split
			#print msg
			if msg[0] =~ /^LAK$/ && msg[2]
				@tgate_name = msg[2]
				return true
			end
		end
		def to_s
			"#{@code}, #{@license_number}\n"
			#"#{@code}, #{@vehicle_id}, #{@location_known}  #{@tgate_name if defined? @tgate_name}\nVehicle Info: #{@license_number}, #{@description}, #{@vehicle_type}\n"
		end
	end
end

a=Simulator::IVTU_simulator.new

#time dilation: 1/60?
#3 hrs would yield 3 minutes
#
