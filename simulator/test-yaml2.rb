require 'yaml'

class Record
	attr_accessor   :foo,:bar
	
	def initialize
	  puts "in initialize", self
  end
  def to_yaml_type
    "!arl.amrita.edu,2006/record"
  end
end
YAML::add_domain_type( "arl.amrita.edu,2006", "record" ) do
           |type, val|
           puts "in type hook"
           p type,val
           puts "out of type hook"
#           val['type'] = "hash"
           YAML.object_maker( Record, val )
       end
r = Record.new
r.bar = "asdf"
r.foo = "fdsa"

File.open( "record.yaml", "w" ) { |f| YAML::dump r, f }
puts IO.readlines( "record.yaml")

new_r = YAML::load_file "record.yaml"
puts new_r.inspect