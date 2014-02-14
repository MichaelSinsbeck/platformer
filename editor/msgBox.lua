msgBox = {}

function msgBox:new( msg, eventAccept, eventDecline )
	--[[if msgBox.active then
		msgBox:delete()
	end]]
	msgBox.msg = string.lower(msg)

	msgBox.eventAccept = function()
		msgBox:delete() -- must be called before event, in case event creates new message box!
		if eventAccept then
			eventAccept()
		end
	end

	msgBox.eventDecline = function()
		msgBox:delete() -- must be called before event, in case event creates new message box!
		if eventDecline then
			eventDecline()
		end
	end

	local width = love.graphics.getWidth()/3/Camera.scale
	local __,lines = fontSmall:getWrap(msgBox.msg, (width-16)*Camera.scale)
	local textHeight = lines*fontSmall:getHeight()
	local height = textHeight/Camera.scale + 25
	local x = love.graphics.getWidth()/2/Camera.scale - width/2
	local y = love.graphics.getHeight()/2/Camera.scale - height/2
	msgBox.panel = Panel:new( x, y, width, height )

	msgBox.textX = (x + 8)*Camera.scale
	msgBox.textY = (y + 6)*Camera.scale
	msgBox.textWidth = (width-16)*Camera.scale

	msgBox.panel:addClickable( 15, textHeight/Camera.scale + 16, msgBox.eventAccept,
				'LEAcceptOff',
				'LEAcceptOn',
				'LEAcceptHover',
				'Accept', nil, nil, 'return', true )
	msgBox.panel:addClickable( 28, textHeight/Camera.scale + 16, msgBox.eventDecline,
				'LEDeleteOff',
				'LEDeleteOn',
				'LEDeleteHover',
				'Decline', nil, nil, 'escape', true )

	msgBox.active = true

end

function msgBox:collisionCheck( x, y )
	return msgBox.panel:collisionCheck( x, y )
end

function msgBox:click( x, y, clicked )
	return msgBox.panel:click( x, y, clicked )
end

function msgBox:delete()
	msgBox.active = false
end

function msgBox:update( dt )
	msgBox.panel:update( dt )
end

function msgBox:draw()
	msgBox.panel:draw()
	love.graphics.setFont( fontSmall )
	love.graphics.printf( msgBox.msg, msgBox.textX, msgBox.textY, msgBox.textWidth )
end

