-- config file handling, can save and load config data

local config = {}

local CONFIG_FILE = "config.txt"

function config.setValue( name, value, filename )
	--print("saving:", name, value)
	
	filename = filename or CONFIG_FILE	-- default to configfile
	
	if not name or not value == nil then
		print(name, value)
		error("Error: configFile.setValue got nil value or nil name.")
	end
	
	if not love.filesystem.isFile( filename ) then
		local file = love.filesystem.newFile( filename )
		file:open('w')	--create the file
		file:close()
	end
	
	if type(value) ~= "string" then
		value = tostring(value)
	end
	
	local file = love.filesystem.newFile( filename )
	local data
	if file then
		file:open('r')
		data = file:read()
		file:close()
	end
	
	if not data then
		data = ""
	end
	

	local newData = ""
	local found = false
	--print("full:")
	for line in data:gmatch("[^\r\n]+") do
		--print(line)
		s, e = string.find(line, name .. " = [^\r\n]+")
		if s then
			--data = string.gsub(data, name .. " = [^\r\n]+\r\n", name .. " = " .. value .. "\r\n")
			newData = newData .. name .. " = " .. value .. "\r\n"
			found = true
		else
			newData = newData .. line .. "\r\n"
			--data = data .. name .. " = " .. value .. "\r\n"
		end
	end
	if not found then
		newData = newData .. name .. " = " .. value .. "\r\n"
	end
	
	file = love.filesystem.newFile( filename )
	if file then
		file:open('w')
		file:write(newData)
		file:close()
		return true
	end
end

function config.getValue( name, filename )
	
	filename = filename or CONFIG_FILE	-- default to configfile

	if not love.filesystem.isFile(filename) then
		print("Could not find config file.", name, filename)
		return nil
	end
	local ok, file = pcall(love.filesystem.newFile, filename )
	local data
	if ok and file then
		file:open('r')
		data = file:read()
		file:close()
	end
	if data then
		for k, v in string.gmatch(data, "([^ \r\n]+) = ([^\r\n]+)") do
			if k == name then
				return v
			end
		end
	end
	print("Value for '" .. name .. "' not found in config file.")
	return nil
end

return config
