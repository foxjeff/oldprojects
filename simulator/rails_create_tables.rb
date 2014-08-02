class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :vehicles do |t|
			t.column :license_number,	:string
			t.column :seat_capacity,	:integer
			t.column :vehicle_type,		:string
			t.column :description,		:string
		end

    create_table :ivus do |t|
			t.column :ivu_code,			:string
			t.column :ivu_type,			:string
			t.column :vehicle_id,		:integer
		end

    create_table :fcus do |t|
			t.column :fcu_code,			:string
			t.column :fcu_type,			:string
			t.column :last_message_timestamp,	:timestamp
			t.column :reg_password,	:string
		end

    create_table :nodes do |t|
			t.column :node_code,		:string
			t.column :description,	:string
			t.column :short_name,		:string
			t.column :fcu_id,				:integer
    end

    create_table :tdc_servers do |t|
			t.column :tdcs_code,				:string
			t.column :descriptive_name,	:string
    end

    create_table :telematics_messages do |t|
			t.column :message_timestamp,	:timestamp
			t.column :message_attributes,	:text
			t.column :received_timestamp,	:timestamp
			t.column :fcu_id,							:integer
			t.column :ivu_id,							:integer
			t.column :message_id,					:integer
    end

    create_table :message_types do |t|
			t.column :fu_type,		:string
			t.column :main_type,		:string
			t.column :sub_type,			:string
			t.column :description,	:string
    end

    create_table :trips do |t|
			t.column :scheduled_time,	:datetime
			t.column :route_id,				:integer
			t.column :vehicle_id,			:integer
    end

    create_table :current_trips do |t|
			t.column :seat_availability,	:integer
			t.column :timestamp,					:timestamp
			t.column :description,				:string
			t.column :current_node_id,		:integer
			t.column :trip_id,						:integer
    end

    create_table :trip_traces do |t|
			t.column :seat_availability,	:integer
			t.column :timestamp,					:timestamp
			t.column :node_id,						:integer
			t.column :trip_id,						:integer
    end
  
    create_table :trip_node_time_estimates do |t|
			t.column :estimate_ttt,	:time
			t.column :edges_id,			:integer
			t.column :trip_id,			:integer
    end
  
		create_table :routes do |t|
			t.column :route_code,		:string
			t.column :description,	:string
		end

		create_table :route_edges do |t|
			t.column :edge_order,			:integer
			t.column :route_id,				:integer
			t.column :start_node_id,	:integer
			t.column :end_node_id,		:integer
		end
	end

  def self.down
    drop_table :vehicles
    drop_table :ivus
    drop_table :fcus
    drop_table :nodes
    drop_table :tdc_servers
    drop_table :telematic_messages
    drop_table :message_types
    drop_table :trips
    drop_table :current_trips
    drop_table :trip_traces
    drop_table :trip_node_time_estimates
		drop_table :routes
		drop_table :route_edges
  end
end
