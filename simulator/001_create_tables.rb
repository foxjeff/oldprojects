#!/usr/bin/env ruby
#other stuff

module Itews_db

	require 'yaml'
	require 'numeric_hours.rb'

	Telematics_messages_struct = 
		Struct::new(
			create_table :TelematicMessages do |t|
			:id,
			# foreign_keys:
			t.column :message_type,				:string
			t.column :message_sub_type,		:string
			t.column :source_addr,				:integer #i.e. node_id, or tgate_id
			t.column :destination_addr,		:integer
			t.column :vehicle_id,					:integer
			# attributes:
			t.column :message_timestamp,	:timestamp
			t.column :message_attributes,	:text
			t.column :received_timestamp	:timestamp
			)

	Vehicle_master_struct = 
		Struct::new(
			create_table :VehicleMaster do |t|
			:id,
			# foreignKeys:
			# attributes:
			t.column :license_number,	:string
			t.column :seat_capacity,	:integer
			t.column :type,						:string
			t.column :description			:string
			)

	Message_master_struct =
		Struct::new(
			create_table :MessageMaster do |t|
			:id,
			# foreign_keys:
			# attributes:
			t.column :type,					:string
			t.column :sub_type,			:string
			t.column :source_type,	:string
			t.column :description		:string
			)

	TDCS_master_struct =
		Struct::new(
			create_table :TDCSMaster do |t|
			:id,
			# foreign_keys:
			# attributes:
			t.column :tdcs_id,					:string
			t.column :descriptive_name	:string
			)

	TGATE_master_struct =
		Struct::new(
			create_table :TGATEMaster do |t|
			:id,
			# foreign_keys:
			t.column :node_id,			:integer
			# attributes:
			t.column :tgate_addr,		:string
			t.column :station_name,	:string
			t.column :ip_addr,			:string
			t.column :status				:string
			)

	Node_master_struct =
		Struct::new(
			create_table :NodeMaster do |t|
			:id,
			t.column :node_code,		:string
			# foreign_keys:
			# attributes:
			t.column :description		:string
			)

	Trip_master_struct =
		Struct::new(
			create_table :TripMaster do |t|
			:id,
			# foreign_keys:
			t.column :route_id,			:integer
			t.column :vehicle_id		:integer
			# attributes:
			)

	Route_master_struct =
		Struct::new(
			create_table :RouteMaster do |t|
			:id,
			# foreign_keys:
			# attributes:
			t.column :node_list,					:text
			t.column :route_description		:string
			)

	Trip_current_struct =
		Struct::new(
			create_table :TripCurrent do |t|
			:id,
			# foreign_keys:
			t.column :current_node_id,		:integer
			t.column :trip_id,						:integer
			# attributes:
			t.column :description,				:string
			t.column :seat_availability,	:integer
			t.column :timestamp						:timestamp
			)

	Trip_trace_struct =
		Struct::new(
			create_table :TripTrace do |t|
			:id,
			# foreign_keys:
			t.column :node_id,						:integer
			t.column :trip_id,						:integer
			# attributes:
			t.column :seat_availability,	:integer
			t.column :timestamp						:timestamp
			)

	Trip_node_time_estimates_struct =
		Struct::new(
			create_table :TripNodeTimeEstimates do |t|
			:id,
			# foreign_keys:
			t.column :destination_id,	:integer
			t.column :source_id,			:integer
			t.column :trip_id,				:integer
			# attributes:
			t.column :estimate_ttt		:time
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


