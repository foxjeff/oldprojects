#!/usr/bin/env ruby -w
module Simulator_db

	require 'dbi'
	require 'singleton'

	class DB_handle
		def db_handle << self
			@@db_handle = DBI.connect('DBI:Mysql:simulator_development','root','') unless @@db_handle
			@@db_handle
		end
	end
end

