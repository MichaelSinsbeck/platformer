-- A Submenu is made up of one or more layers, each layer can have any number of panels.
-- Buttons are usually displayed on the panels.

local Panel = require( "scripts/menu/menuPanel" )
local Button = require( "scripts/menu/button" )

local Submenu = {}
Submenu.__index = Submenu

function Submenu:new()
	local o = {}
	o.layers = {}

	setmetatable( o, self )

	o:addLayer( "MainLayer" )

	return o
end

function Submenu:draw()
	for k,l in ipairs( self.layers ) do
		if l.visible then

			-- Draw all images on this layer:
			for j, i in ipairs( l.images ) do
				love.graphics.draw( AnimationDB.image[i.image], i.x*Camera.scale, i.y*Camera.scale )
			end

			-- Draw the panels on this layer:
			for j, p in ipairs( l.panels ) do
				p:draw()
			end

			-- Draw the buttons on this layer:
			for j, b in ipairs( l.buttons ) do
				b:draw()
			end
		end
	end
end

function Submenu:update( dt )
	for k,l in ipairs( self.layers ) do
		if l.visible then
			for j, b in ipairs( l.buttons ) do
				b:update( dt )
			end
		end
	end
end


function Submenu:addLayer( layerName )
	local layer = {
		name = layerName,
		visible = true,
		panels = {},
		images = {},
		buttons = {},
	}

	table.insert( self.layers, layer )
end

function Submenu:setLayerVisible( layerName, bool )
	self.layers[layerName].visible = bool
end

function Submenu:addPanel( x, y, w, h, layerName )

	-- Per default, add panels to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local p = Panel:new( x, y, w, h )
			table.insert( l.panels, p )
			return p
		end
	end
end

function Submenu:addButton( imgOff, imgOn, x, y, event, eventHover, layerName )
	
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local b = Button:new( imgOff, imgOn, x, y, event, eventHover )
			table.insert( l.buttons, b )
			return b
		end
	end

end

function Submenu:addImage( image, x, y, layerName )
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local i = {
				image = image,
				x = x,
				y = y,
			}
			table.insert( l.images, i )
		end
	end
end

return Submenu
