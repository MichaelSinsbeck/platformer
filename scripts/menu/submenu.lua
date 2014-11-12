-- A Submenu is made up of one or more layers, each layer can have any number of panels.
-- Buttons are usually displayed on the panels.

local Panel = require( "scripts/menu/menuPanel" )

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
			for j, i in ipairs( l.images ) do
				love.graphics.draw( AnimationDB.image[i.image], i.x*Camera.scale, i.y*Camera.scale )
			end
			for j, p in ipairs( l.panels ) do
				p:draw()
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

function Submenu:addButton()
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
