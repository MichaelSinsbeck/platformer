
local RatingSubmenu = {}
local Submenu = require( "scripts/menu/submenu" )
local submenu	-- use this to remember the current sub menu
local UserlevelSubmenu = require( "scripts/menu/userlevelSubmenu" )

function RatingSubmenu:new( x, y )
	local width = 96
	local height = 48

	submenu = Submenu:new( x, y )

	local p = submenu:addPanel( -width/2, -height/2, width, height );

	local fun = 3
	local difficulty = 3

	local sliderFun
	local sliderDifficulty

	local setFun = function( value )
		fun = value
		print("fun:", value)
	end
	local setDifficulty = function( value )
		difficulty = value
		print("difficulty:", value)
	end
	local enterPressedOnFunSlider = function()
		submenu:setSelectedButton( sliderDifficulty )
	end
	local back = function()
		menu:switchToSubmenu("Userlevels")
		menu:show()
	end
	local rate = function( value )
		self:rate( fun, difficulty )
		menu:switchToSubmenu("Userlevels")
		menu:show()
	end

	submenu:addText( "Would you like to rate this level?", -34, -14, width, "MainLayer", "left", {0,0,0} )

	local sX, sY = -32, -8
	sliderFun = submenu:addSlider( "stars", sX, sY, 50,
		menu:setPlayerPositionEvent( x+sX-2, y+sY+5 ), setFun, "Fun: " )
	sliderFun:setEventChoose( enterPressedOnFunSlider )
	sliderFun:setValue( 3 )

	sX, sY = -32, 2
	sliderDifficulty = submenu:addSlider( "skulls", sX, sY, 50,
		menu:setPlayerPositionEvent( x+sX-2, y+sY+5 ), setDifficulty, "Difficulty: " )
	sliderDifficulty:setEventChoose( rate );
	sliderDifficulty:setValue( 3 )

	submenu:addHotkey( "BACK", "Skip Rating",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		back )

	submenu:addHotkey( "CHOOSE", "Rate",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		rate )

	return submenu
end

function RatingSubmenu:rate( ratingFun, ratingDifficulty )
	local levelname, author = UserlevelSubmenu:getSelectedLevelData()
						print( "Rating:", levelname, author, ratingFun, ratingDifficulty )
	threadInterface.new( "levelrating", "scripts/levelsharing/rate.lua", "rate",
						function( data ) self:success( data ) end,
						function( data ) self:failed( data ) end,
						levelname, author, ratingFun, ratingDifficulty	)
end

function RatingSubmenu:success( data )
	print( "Sucessfully rated level:", data )
end

function RatingSubmenu:failed( data )
	print( "Failed to rate level:", data )
end

return RatingSubmenu
