-- Minimalistic Profiler for measuring times over multiple frames

local profiler = {}

profiler.data = {}


function profiler:register(key, value)
	if not self.data[key] then
		self.data[key] = {value = 0, calls = 0}
	end
	self.data[key].value = profiler.data[key].value + value
	self.data[key].calls = profiler.data[key].calls + 1
end

function profiler:clear()
	self.data = {}
end

function profiler:report()
	print ('Profiler Report')
	for key,v in pairs(self.data) do
		local value = v.value
		local calls = v.calls
		if calls > 0 then
			local averg = value/calls
			-- Print data
			print (' ' .. key)
			print(string.format('          Sum: %1.2e, Average: %1.2e',value,averg))
		end
	end
end

return profiler
