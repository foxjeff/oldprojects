load 'CommandAndControl.rb'
cc=CommandAndControl.new
times=cc.times_from_timeline.sort!
puts "going now"
tt=Time.now
(tt..tt+600).step(10) do
	|t|
	tc=0
	break if times.size == 0
	times.each do
		|ti| 
		if t > ti - 10
			p ti
			puts "shifting #{tc += 1}"
		end
	end
	tc.times {times.shift}
end
