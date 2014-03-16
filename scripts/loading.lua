


local loading = {
	step = -1,
	msg = "scripts",
}

-- Every time this function is called, the next step will be loaded.
-- Important: the loading.msg must be set to the name of the NEXT module, not the current one,
-- because love.draw gets called after love.update.
function loading.update()

	if loading.step == 0 then
		menu = require("scripts/menu")
		BambooBox = require("scripts/bambooBox")
		
		-- loads all scripts and puts the necessary values into the global
		-- environment:
		keys = require("scripts/keys")
		--require("scripts/misc")
		shaders = require("scripts/shaders")

		require 'scripts/utility'
		require 'scripts/game'
		--require 'scripts/spritefactory'
		Map = require 'editor/editorMap'
		require 'scripts/campaign'
		require 'scripts/levelEnd'
		require 'scripts/bridge'
		objectClasses = require 'scripts/objectclasses'
		
		loading.msg = "camera"
	elseif loading.step == 1 then
		Camera:applyScale()
		loading.msg = "keyboard setup"
	elseif loading.step == 2 then
		keys.load()
		loading.msg = "gamepad setup"
	elseif loading.step == 3 then
		keys.loadGamepad()
		loading.msg = "menu"
	elseif loading.step == 4 then
		menu:init()	-- must be called after AnimationDB:loadAll()
		BambooBox:init()
		loading.msg = "shaders"
	elseif loading.step == 5 then	
		if USE_SHADERS then
			shaders.load()
		end
		loading.msg = "campaign"
	elseif loading.step == 6 then
		recorder = false
		screenshots = {}
		recorderTimer = 0

		timer = 0

		Campaign:reset()
		loading.msg = "levels"	
	elseif loading.step == 7 then
		levelEnd:init()
		loading.msg = "shadows"
	elseif loading.step == 8 then
		shadows = require("scripts/monocle")
		loading.msg = "editor"
	elseif loading.step == 9 then
		editor = require("editor/editor")
		-- editor.init()
		loading.msg = "menu"
	elseif loading.step == 10 then
		menu.initMain()
		-- temporary
		--springtime = love.graphics.newImage('images/transition/silhouette.png')
		--bg_test = love.graphics.newImage('images/menu/bg_main.png')		
	end
	loading.step = loading.step + 1
end

function loading.draw()
	--os.execute("sleep .5")
	love.graphics.setColor(255,255,255,255)
	local str = "loading: " .. loading.msg
	--print(str)
	
	love.graphics.setColor(150,150,150)
	love.graphics.setFont(fontSmall)
	love.graphics.print(str, Camera.scale*5, love.graphics.getHeight()-Camera.scale*8)
	
	love.graphics.setColor(44,90,160)
	love.graphics.setFont(fontLarge)
	love.graphics.printf('loading', 0, 0.5*love.graphics.getHeight(), love.graphics.getWidth(), 'center')
end

function loading.preload()
-- This function does everything that is necessary before the loading 
-- screen can be shown: Set graphical mode and load font.
	Camera:init()	
	loadFont()	

	-- hide mouse
	love.mouse.setVisible(false)
	
	mode = 'loading'	
end

return loading
