class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :vehicles do |t|
			t.column :license_number,	:string
			t.column :seat_capacity,	:integer
			t.column :vehicle_type,		:string
			t.column :description,		:string
		end

    create_table :nodes do |t|
			t.column :node_code,		:string
			t.column :description,	:string
			t.column :short_name,		:string
			t.column :fcu_id,				:integer
    end

    create_table :trips do |t|
			t.column :scheduled_time,	:datetime
			t.column :route_id,				:integer
			t.column :vehicle_id,			:integer
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
    drop_table :nodes
    drop_table :trips
		drop_table :routes
		drop_table :route_edges
  end
end
