require 'basecamp.rb'
require 'yaml'
#require 'ActionView'
require 'action_view/helpers/date_helper'
require 'active_support/core_ext/date'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/time'

include ActionView::Helpers::DateHelper
include ActiveSupport::CoreExtensions::Date::Conversions
include ActiveSupport::CoreExtensions::Time::Calculations
include ActiveSupport::CoreExtensions::Time::Conversions

$f = File.open( "basecamp-projects.yaml", "w" )

def write_item item
  YAML.dump item,$f
end

b=Basecamp.new "arl-amrita.projectpath.com" ,"anandfox", "ammanand"
# projects
ps = b.projects
write_item( ps )

ps.each {|p| puts "#{p['name']} was last changed #{p['last-changed-on'].class==Time ? distance_of_time_in_words_to_now(p['last-changed-on']) : "has never been changed" } ago"}

project_ids = []
ps.each { |p| project_ids << p.id}

#companies
project_ids.each do
	|p|
	companies = b.companies p
	write_item companies
end

#people
companies.each { |c| write_item b.people c.id }

#messages
project_ids.each do
  |p|
  puts "processing","#{Kernel.p p}"
  messages_archive = b.message_list p
  message_ids = []
  messages_archive.each { |m| message_ids << m.id }
  mod25, throwaway = message_ids.size.divmod 25
  (mod25+1).times do
    break  if message_ids.size == 0
    message_group = message_ids.slice(0..24)
    puts "processing","#{Kernel.p message_group}"
    messages = []
    messages << b.message( message_group )
    message_ids = message_ids - message_group
    messages.flatten.each do
      |message|
      write_item message
      write_item( b.comments message.id ) unless message.comments_count == 0
    end
  end
end

#milestones
project_ids.each { |p| write_item( b.milestones p ) }
#milestones = []
#ps.each { |pr| milestones << b.milestones( pr.id ) }
#milestones.each { |ms| ms.each { |m| puts m.title }}
#milestones.flatten!
#puts milestones.size

#todo lists
project_ids.each { |p| write_item( b.lists p ) }
#lists = {}
#lists.each { |l| puts "TODO Lists for project:#{l[0].name}:"; puts  "#{p l}" }

$f.close



__END__

re-create xml, needs to be specific for 'rootname' option:
puts XmlSimple.xml_out xm, {'keeproot'=>false,'contentkey'=>'__content__','rootname'=>'projects'}

create yaml-type hashes:
xm= XmlSimple.xml_in b.xml_response, {'forcearray'=>false,'keeproot'=>false,'forcecontent'=>true,'contentkey'=>'__content__'}

 message_ids.each do
    |message_id|
    write_item( b.message message_id )
    write_item( b.comments message_id )
  end
end

def put_list list
  puts "#{list.name}, #{list.date}"
end
TODO Lists for project:Cyber Security: list[0].name
[#<Record(project) 
  "name"=>"Cyber Security", "status"=>"active", 
  "company"=>{"name"=>"Amrita Research Labs", "id"=>391679}, 
  "created-on"=>#<Date: 4908161/2,0,2299161>,
   "last-changed-on"=>Thu Dec 21 04:11:28 UTC 2006, 
   "id"=>772668>,
    [#<Record(todo-list)
      "name"=>"Steps for setting up Cyber Security Lab in Ettimadai",
      "completed-count"=>0, "milestone-id"=>{}, "private"=>false, "tracked"=>false, 
      "project-id"=>772668, "id"=>1464324, "description"=>nil, "complete"=>"false", 
      "position"=>1, "uncompleted-count"=>6>]
]
