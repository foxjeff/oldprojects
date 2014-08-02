require 'monitor'
class Foo
	include MonitorMixin

	@@poo=""
	@@poo.extend(MonitorMixin)

	def self.poo=(_poo)
		include MonitorMixin
		@@poo.extend(MonitorMixin)
		@@poo.synchronize do
			@@poo = _poo
		end
	end
	def self.poo
		@@poo
	end
	def self.boo
		th=Thread.new { sleep 0.5; self.poo = "far" }
		th.join
	end
end

Foo::poo="bar"
puts Foo::poo
Foo::boo
puts Foo::poo
puts Foo::poo
