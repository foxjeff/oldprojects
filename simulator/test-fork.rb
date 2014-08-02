#!/usr/bin/env ruby -w
#

tdcs_pid= fork { system("ruby tdcs_simulator.rb > foo3") }
puts "tdcs forked as process: #{Process.detach tdcs_pid}"
ivtu_pid= fork { system("ruby ivtu_simulator.rb >> foo3") }
puts "ivtu forked as process: #{Process.detach ivtu_pid}"
tgate_pid= fork { system("ruby tgate_simulator.rb >> foo3") }
puts "tgate forked as process: #{Process.detach tgate_pid}"

trap("CLD") {
	pid=Process.wait
	puts "child: #{pid}, status: #{$?}"
	File.open("foo3","r") { |f| puts f.readline.chomp! until f.eof if tdcs_pid }
	puts "finished"
}
trap("INT") {
	exit true
}
sleep 10000

