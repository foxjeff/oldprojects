#url to delete a mac address from acl
#<a href=privacy.htm?MAC_ADDR=00:0C:41:15:C8:74>
#curl -N -v -u admin:ammaamma http://10.1.253.1/privacy.htm?MAC_ADDR=00:0C:41:15:C8:74

#url to reboot ap
#<a href=reboot.htm>
#http://10.1.253.1/reboot.htm

#to add mac addr
#curl -N -v -u admin:ammaamma http://10.1.253.1/privacy.htm -d privacy=privnew.htm -d acl_MacAddr=00:0C:41:15:C8:74 -d acl_PermitIdx=1 -d acl_Key=

require 'net/http'
require 'uri'
MAC_ADDR='00:0C:41:15:C8:74'
	def add_mac
		system "curl -u admin:amma http://10.1.253.1/privacy.htm -d privacy=privnew.htm -d acl_MacAddr=#{MAC_ADDR} -d acl_PermitIdx=1 -d acl_Key="
		system "curl -u admin:ammaamma http://10.1.253.1/reboot.htm"
	end
	def add_mac2
		url = URI.parse('http://10.1.253.1/privacy.htm')
		req = Net::HTTP::Post.new(url.path)
		req.basic_auth 'admin', 'ammaamma'
		req.set_form_data({
			'privacy'       => 'privnew.htm',
			'acl_MacAddr'   => MAC_ADDR,
			'acl_PermitIdx' => 1,
			'acl_Key'       => nil
			}, ';')
		response = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
	end


	def delete_mac
		system "curl -u admin:ammaamma http://10.1.253.1/privacy.htm?MAC_ADDR=#{MAC_ADDR}"
		system "curl -u admin:ammaamma http://10.1.253.1/reboot.htm"
	end
	def delete_mac2
		url = URI.parse('http://10.1.253.1/privacy.htm')
		req = Net::HTTP::Get.new(url.path)
		req.basic_auth 'admin', 'ammaamma'
		req.set_form_data({'MAC_ADDR'=>MAC_ADDR})
		#begin
			response = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
		#rescuse Exception => e
			#puts e
		#ensure
			#p response
		#end
	end
	def test_add
		system "curl -N -v -u admin:password http://192.168.10.227/cgi-bin/acl.cgi?acl.html -d setobject_aclmac=ignore -d setobject_aclmac_addordelete=ignore -d setobject_aclmode=1 -d deny_maclist= -d allow_maclist=00%3A0C%3A41%3A15%3AC8%3A74%2000%3A0C%3A41%3A6C%3A78%3A80"
	end
	def test_delete
		system "curl -N -v -u admin:password http://192.168.10.227/cgi-bin/acl.cgi?acl.html -d setobject_aclmac=ignore -d setobject_aclmac_addordelete=ignore -d setobject_aclmode=1 -d allow_maclist=00%3A0C%3A41%3A6C%3A78%3A80 -d deny_maclist="
	end
