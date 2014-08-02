#!/usr/bin/env ruby

module Utility

	require 'net/http'
	require 'uri'

	MAC_ADDR_ADD   = URI.escape("00:0C:41:15:C8:74 00:0C:41:6C:78:80", /[ :]/)
	MAC_ADDR_DEL   = URI.escape("00:0C:41:6C:78:80", /[ :]/)
	AP_IP          = 'http://192.168.10.227'
	ADMIN          = 'admin'
	ADMIN_PASSWORD = 'password'
	AP_USER_INFO   = "#{ADMIN}:#{ADMIN_PASSWORD}"
	CGI_PATH       = "/cgi-bin/acl.cgi?acl.html"

	def add_mac
	  return
		system "curl -u #{AP_USER_INFO} #{AP_IP}#{CGI_PATH} -d setobject_aclmac=ignore -d setobject_aclmac_addordelete=ignore -d setobject_aclmode=1 -d allow_maclist=#{MAC_ADDR_ADD} -d deny_maclist="
	end
	def add_mac2
			#still not working; capturing output shows
#% nc -l -p 9999
#POST /cgi-bin/acl.cgi HTTP/1.1
#Accept: */*
#Content-Type: application/x-www-form-urlencoded
#Authorization: Basic YWRtaW46cGFzc3dvcmQ=
#Content-Length: 165
#Host: localhost:9999

#setobject_aclmac_addordelete=ignore;setobject_aclmac=ignore;setobject_aclmode=1;allow_maclist=00%3a0C%3a41%3a15%3aC8%3a74%2000%3a0C%3a41%3a6C%3a78%3a80;deny_maclist=
# the ";" look suspect, even though we get back a 200 response
# also the url is mangled, the path is supposed to be as above

		url = URI.parse(AP_IP)
		#url = URI.parse('http://localhost')
		url.merge! CGI_PATH
		req = Net::HTTP::Post.new(url.path)
		req.basic_auth(ADMIN, ADMIN_PASSWORD)
		req.set_form_data({
			'setobject_aclmac'             => 'ignore',
			'setobject_aclmac_addordelete' => 'ignore',
			'setobject_aclmode'            => 1,
			'allow_maclist'                => "00:0C:41:15:C8:74 00:0C:41:6C:78:80", #MAC_ADDR_ADD,
			'deny_maclist'                 => nil
			}, ';')
		response = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
		response
		#response = Net::HTTP.new('localhost', 9999).start {|http| http.request(req) }
	end


	def delete_mac
	  return
		system "curl -u #{AP_USER_INFO} #{AP_IP}#{CGI_PATH} -d setobject_aclmac=ignore -d setobject_aclmac_addordelete=ignore -d setobject_aclmode=1 -d allow_maclist=#{MAC_ADDR_DEL} -d deny_maclist="
	end
	def delete_mac2
		url = URI.parse(AP_IP)
		url.merge! CGI_PATH
		req = Net::HTTP::Post.new(url.path)
		req.basic_auth(ADMIN, ADMIN_PASSWORD)
		req.set_form_data({
			'setobject_aclmac'             => "ignore",
			'setobject_aclmac_addordelete' => "ignore",
			'setobject_aclmode'            => 1,
			'allow_maclist'                => "00:0C:41:6C:78:80", #MAC_ADDR_DEL,
			'deny_maclist'                 => nil
			}, ';')
		response = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
		response
	end
	def start_ivtu_sim 
		system "./ivtu_simulator.rb"
	end
end
