#!/usr/bin/env ruby
#other stuff

module Itews_db

	require 'yaml'
	require 'numeric_hours.rb'

	Telematics_messages_struct = 
		Struct::new(
			"TelematicMessages",
			:id,
			# foreign_keys:
			:message_type,
			:message_sub_type,
			:source_addr,				#i.e. node_id, or tgate_id
			:destination_addr,
			:vehicle_id,
			# attributes:
			:message_timestamp,
			:message_attributes,
			:received_timestamp
			)

	Vehicle_master_struct = 
		Struct::new(
			"VehicleMaster",
			:id,
			# foreignKeys:
			# attributes:
			:license_number,
			:seat_capacity,
			:type,
			:description
			)

	Message_master_struct =
		Struct::new(
			"MessageMaster",
			:id,
			# foreign_keys:
			# attributes:
			:type,
			:sub_type,
			:source_type,
			:description
			)

	TDCS_master_struct =
		Struct::new(
			"TDCSMaster",
			:id,
			# foreign_keys:
			# attributes:
			:tdcs_id,
			:descriptive_name
			)

	TGATE_master_struct =
		Struct::new(
			"TGATEMaster",
			:id,
			# foreign_keys:
			:node_id,
			# attributes:
			:tgate_id,
			:station_name,
			:ip_addr,
			:status
			)

	Node_master_struct =
		Struct::new(
			"NodeMaster",
			:id,
			:node_code,
			# foreign_keys:
			# attributes:
			:description
			)

	Trip_master_struct =
		Struct::new(
			"TripMaster",
			:id,
			# foreign_keys:
			:route_id,
			:vehicle_id
			# attributes:
			)

	Route_master_struct =
		Struct::new(
			"RouteMaster",
			:id,
			# foreign_keys:
			# attributes:
			:node_list,
			:route_description
			)

	Trip_current_struct =
		Struct::new(
			"TripCurrent",
			:id,
			# foreign_keys:
			:current_node_id,
			:trip_id,
			# attributes:
			:description,
			:seat_availability,
			:timestamp
			)

	Trip_trace_struct =
		Struct::new(
			"TripTrace",
			:id,
			# foreign_keys:
			:node_id,
			:trip_id,
			# attributes:
			:seat_availability,
			:timestamp
			)

	Trip_node_time_estimates_struct =
		Struct::new(
			"TripNodeTimeEstimates",
			:id,
			# foreign_keys:
			:destination_id,
			:source_id,
			:trip_id,
			# attributes:
			:estimate_ttt
			);
	
end

tm = Itews_db::Telematics_messages_struct.new
tm.id = 11
tm.message_type = 'a good one'
puts tm.to_yaml

vm = Itews_db::Vehicle_master_struct.new
vm.id = 12
vm.license_number = "ckl 549"
puts vm.to_yaml

mm = Itews_db::Message_master_struct.new
mm.id = 13
mm.type = :LUP
mm.sub_type = :actual
mm.source_type = :tgate
mm.description = "fair and warmer today"
puts mm.to_yaml

tdm = Itews_db::TDCS_master_struct.new
tdm.id = 14
tdm.tdcs_id = 114
tdm.descriptive_name = "SimEng tdcs master"
puts tdm.to_yaml

tgm = Itews_db::TGATE_master_struct.new
tgm.id = 15
tgm.node_id = 115
tgm.tgate_id = "TG001"
tgm.station_name = "Kollam Station"
tgm.ip_addr = '192.168.0.233'
tgm.status = 'good'
puts tgm.to_yaml

nm = Itews_db::Node_master_struct.new
nm.id = 16
nm.node_code = :tgate
nm.description = "a very nice node indeed"
puts nm.to_yaml

trm = Itews_db::Trip_master_struct.new
trm.id = 17
trm.route_id = 117
trm.vehicle_id = 12
puts trm.to_yaml

rtm = Itews_db::Route_master_struct.new
rtm.id = 18
rtm.node_list = "16, 17, 18"
rtm.route_description = "a nice route"
puts trm.to_yaml

tc = Itews_db::Trip_current_struct.new
tc.id = 19
tc.current_node_id = 16
tc.trip_id = 17
tc.description = "a very nice trip"
tc.seat_availability = 23
tc.timestamp = Time.now
puts tc.to_yaml

tt = Itews_db::Trip_trace_struct.new
tt.id = 20
tt.node_id = 16
tt.trip_id = 17
tt.seat_availability = 23
tt.timestamp = Time.now
puts tt.to_yaml

ttt = Itews_db::Trip_node_time_estimates_struct.new
ttt.id = 21
ttt.destination_id = 18
ttt.source_id = 19
ttt.trip_id = 17
ttt.estimate_ttt = 12.hours
puts ttt.to_yaml


