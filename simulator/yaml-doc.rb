# a round trip with yaml
# a new Struct is created, fs, then instantiated as ff
# the ff object (an fs Struct) is saved to a .yaml file
# the .yaml file is read back in and the object reconstituted
# the new ff2 is compared to the original ff and found to be equivalent
#
require 'yaml'
require 'pp'

fs=Struct::new("FoodStruct", :name, :taste)

ff=fs.new("Nachos", "yummy")

File.open('food.yaml', 'w') do |out| YAML.dump ff,out; end

ff2= File.open('food.yaml') {|f| YAML::load f}

puts ff==ff2,"ff: #{ff}", "ff2: #{ff2}"
pp ff==ff2,"ff: #{ff}", "ff2: #{ff2}"
