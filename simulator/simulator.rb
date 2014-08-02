module Simulator
# move the module Simulator code to its own file and require it in the three sims
#
# these notes are regarding the tgate UDP simulator server process
# of course all Telematics have MESSAGE_MAIN_TYPE in position 0
#

	require 'socket'
	require 'monitor'
	require 'rubygems'
	require 'highline/import'
	require 'dbi'

	#used to convert to/from rabbit timestamps
	#actual tgates have rabbits that use 1980,1,1 as the epoch
	#we will subtract this delta from our timestamps to recreate this
	RABBIT_EPOCH_DELTA= Time.utc(1980,1,1).to_i

	# tgate is 10.1.254.254 (don't foget to: sudo ifconfig en0 alias 10.1.254.254 netmask 255.255.0.0) 
	TDCS_IP						= '127.0.0.1'		# 192.168.0.233
	TDCS_PORT					= 9090
	TGATE_IVTU_IP			= 'tgate'
	TGATE_PORT				= 9090

	CnC_IP						= '127.0.0.1'
	#sims server these ports for CnC (Command aNd Control) connections
	TGATE_CnC_PORT		= 10001
	TDCS_CnC_PORT			= 10002
	IVTU_CnC_PORT			= 10003

	#sims server these ports for output to CnC
	TGATE_CONSOLE_PORT= 11001
	TDCS_CONSOLE_PORT	= 11002
	IVTU_CONSOLE_PORT = 11003

	#console ports served for CnC
	CnC_TGATE_PORT		= 11011
	Cnc_TDCS_PORT			= 11012
	CnC_IVTU_PORT			= 11013

	MAX_RECEIVE_SIZE	= 1024
	# sender for a simulated tgate is an IVTU; these are positions in the sender[]
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


end #module Simulator
