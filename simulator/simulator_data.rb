require 'rubygems'
require "amrita2/template"
include Amrita2

class Vehicle
	attr_accessor	:code
	attr_accessor	:license
	attr_accessor	:current_node
	attr_accessor	:previous_node
	attr_accessor	:last_seen_time

	def initialize(code, license)
		self.code = code
		self.license = license
		self.current_node = self.previous_node = "T00" + rand(7).to_s
		self.last_seen_time = (Time.now - rand(60) * 60).strftime("%H:%M")
	end
  def attribute_replace
    a(:href=>'http://arl.amrita.edu')
  end
end

tmpl = TemplateText.new <<-END
<html>
   <body>
      <h3>Vehicle Info</h3>
      <table border="1" align="center" cellpadding="2" style="width:600;text-align:center">
				<tr>
					<th>Code</th>	
					<th>License</th>	
					<th>Current Node</th>	
					<th>Previous Node</th>	
					<th>Last Seen Time</th>	
				</tr>
				<tr id='vehicles'>
					<td id='code' />
					<td id='license' />
					<td id='current_node' />
					<td id='previous_node' />
					<td id='last_seen_time' />
				</tr>
			</table>
   </body>
</html>
END

#a = Vehicle.new("V001", "KL5-2341")
data = {
:vehicles => [
	Vehicle.new("V001", "KL5-2332"),
	Vehicle.new("V003", "KL4-3055"),
	Vehicle.new("V002", "KL1-3195")
	]
}
foo=""
#tmpl.expand(STDOUT, a)
tmpl.expand(foo, data)
foo.gsub(/<.?html>/,"").gsub(/<.?body>/,"")
print foo.gsub(/\n/, "")
