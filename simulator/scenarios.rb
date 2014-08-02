#!/usr/bin/env ruby -w

module Scenarios

	require 'yaml'
	require 'time'

	YAML::add_domain_type( "arl.amrita.edu,2006", "route" ) do
			|type, val|
			YAML.object_maker( Route, val )
		end

	#constants
	STATION_STAY_DURATION =		20*60		#time buses stay in a station
	DEPARTURE_INTERVAL		=		3*60		#time btwn bus departures/arrivals
	FIRST_STATION_ARRIVAL =		10*60		#time bus arrives to first station
	DEPARTURE_EVENT				=		"Departure"
	ARRIVAL_EVENT					=		"Arrival"

	def random_delta(some_minutes)
		rand(some_minutes)
	end
	def show_scheduled_actual(scheduled_raw, actual_raw, event)
		scheduled = scheduled_raw.divmod(60)
		actual = actual_raw.divmod(60)
		scheduled = "%d:%02d" % [scheduled[0], scheduled[1]]
		actual = "%d:%02d" % [actual[0], actual[1]]
		puts "Scheduled %s: %s,		Actual %s: %s" % [event, scheduled, event, actual]
		[scheduled, actual]
	end

	class Route
		include Scenarios

		attr_accessor :name
		attr_accessor	:nodes
		attr_accessor	:vehicles
		attr_accessor	:current_node

		def initialize(_name, _nodes, _vehicles, _current_node=1)
			self.nodes = _nodes
			self.vehicles = _vehicles
			self.name = _name
			self.current_node = _current_node
		end
		def to_s
			self.to_yaml
		end
		def next_node
			current_node < nodes.size ? current_node + 1 : current_node
		end
		def total_route_time
			#rs.each {|r| p r.name;ttt=0;r.nodes.each {|n| ttt += n['tt']}; p ttt }
			tt = 0
			nodes.each {|n| tt += n['tt']}
			tt
		end
		def to_yaml_type
			"!arl.amrita.edu,2006/route"
		end
		def to_yaml_properties 
			[ '@name', '@nodes', '@vehicles', '@current_node' ] 
		end
	end #class Route

	class Scenario
		include Scenarios

		attr_accessor	:routes
		attr_accessor	:timeline
		attr_accessor	:vehicles
		attr_accessor	:nodes
		attr_accessor	:tcf
		attr_accessor	:name

		def initialize
			self.timeline = {}
			self.vehicles = []
			self.nodes = []
			self.name = []
			self.tcf =   30	#15	# Time Conversion Factor
		end
		def load_routes(yaml_file)
			self.timeline = {}
			self.vehicles = []
			self.nodes = []
			self.name = []
			self.routes = YAML::load_file yaml_file	# "routes.yaml"
			routes.each do
				|r|
				r.current_node=1  # necessary due to some YAML weirdness
				self.vehicles << r.vehicles
				self.nodes << r.nodes 
				self.name << r.name
			end
			routes.each {|s| puts "loaded: #{s.name}"}
		end
		def build_timeline
			station_stay_duration = STATION_STAY_DURATION / tcf	#time buses stay in a station
			departure_interval =		DEPARTURE_INTERVAL		/ tcf		#time btwn bus departures/arrivals
			first_station_arrival = FIRST_STATION_ARRIVAL / tcf	#time bus arrives to first station
			routes.each do
				|route| #scenario = route now 
				puts "processing #{route.name}"
				route.vehicles.each do
					|vehicle|
					puts "	processing #{vehicle['lic']}: #{vehicle['code']}"
					tod_prev = 0	# first node
					route.nodes.each do
						|node|
						puts "		processing #{node['name']}: #{node['code']}"
						this_node = node['code']
						tt = node['tt']*60/tcf
						if node['seq'] == 1
							tod_sched = Time.now + vehicle['tod']*60/tcf
							toa_sched = tod_sched - first_station_arrival
							tod_actul = tod_sched + random_delta(departure_interval)
							toa_actul = toa_sched + random_delta(departure_interval)
						else
							toa_sched = tod_prev + tt
							toa_actul = toa_sched + random_delta(departure_interval)
							tod_sched = toa_actul + station_stay_duration
							tod_actul = tod_sched + random_delta(departure_interval)
						end
						tod_prev = tod_actul
						self.timeline[toa_actul] = {'evt' => 'arrival', 'vehicle'=>vehicle['code'], 'station'=>node['code']}
						self.timeline[tod_actul] = {'evt' => 'departure', 'vehicle'=>vehicle['code'], 'station'=>node['code']}
					end
				end
			end
			timeline.sort.each {|t| p t}
		end #def build_timeline 
	end #class Scenario 

end #module Scenarios
#include Scenarios
#Scenario.new.load_scenarios.build_timeline
			#p scenarios	, scenarios[0].total_route_time, scenarios[0].next_node
			#puts scenarios
#(Time.parse("10:00") + rand(10)*60).strftime "%H:%M"
#rs.each do |r| p r.name; r.vehicles.each do |v| p v['id'];r.nodes.each do |n| print "\t"; p n['name'] ; end; end; puts "---" end
