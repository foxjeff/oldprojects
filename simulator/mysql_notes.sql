--
--
-- this query gets the end_node_id from route_edges for the last node in a route
--    the # 4, would be the current_node_id in current_trips
--	for use in the daemon to remove stale rows from current_trips
--    OR, it would be a given TGate's node_id for use in the TGate Simulator

select re.end_node_id, description from nodes, route_edges re where re.edge_order = (select max(re.edge_order) from route_edges re where re.route_id = 4) and re.route_id = 4 and re.end_node_id = nodes.id;
