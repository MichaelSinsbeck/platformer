
local loading = {
	step = -1,
	msg = "scripts",
}
local proverb
local source

-- Every time this function is called, the next step will be loaded.
-- Important: the loading.msg must be set to the name of the NEXT module, not the current one,
-- because love.draw gets called after love.update.
function loading.update()

	if loading.step == 0 then
		
		love.filesystem.createDirectory("userlevels")

		menu = require("scripts/menu")
		parallax = require("scripts/parallax")
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
		Sound = require 'scripts/sound'
		require 'scripts/sounddb'
		Sound:loadAll()
		require 'scripts/campaign'
		require 'scripts/levelEnd'
		require 'scripts/bridge'
		objectClasses = require 'scripts/objectclasses'

		gui = require('scripts/gui')

		loading.msg = "Camera"
	elseif loading.step == 1 then
		Camera:applyScale()
		loading.msg = "Keyboard Setup"
	elseif loading.step == 2 then
		keys.load()
		loading.msg = "Gamepad Setup"
	elseif loading.step == 3 then
		keys.loadGamepad()
		loading.msg = "Menu"
	elseif loading.step == 4 then
		menu:init()	-- must be called after AnimationDB:loadAll()
		BambooBox:init()
		upgrade = require("scripts/upgrade")		
		love.keyboard.setKeyRepeat( true )
		loading.msg = "Shaders"
	elseif loading.step == 5 then	
		if settings:getShadersEnabled() then
			shaders.load()
		end
		loading.msg = "Editor"
	elseif loading.step == 6 then
		editor = require("editor/editor")
		editor.init()
		loading.msg = "Campaign"
	elseif loading.step == 7 then
		recorder = false
		screenshots = {}
		recorderTimer = 0

		timer = 0

		Campaign:reset()
		Campaign.bandana = config.getValue("bandana") or 'blank'
		loading.msg = "Shadows"
	elseif loading.step == 8 then
		shadows = require("scripts/monocle")
		loading.msg = "Levels"
	elseif loading.step == 9 then
		levelEnd:init()	-- must be called AFTER requiring the editor
		loading.msg = "Menu"
	elseif loading.step == 10 then
		menu.initMain()
		-- temporary
		--springtime = love.graphics.newImage('images/transition/silhouette.png')
		--bg_test = love.graphics.newImage('images/menu/bg_main.png')		

	threadInterface.new( "version info",	-- thread name (only used for printing debug messages)
		"scripts/levelsharing/get.lua",	-- thread script
		"get",	-- function to call (inside script)
		menu.downloadedVersionInfo, nil,	-- callback events when done
		-- the following are arguments passed to the function:
		"version.php" )
	end
	--loading.step = loading.step + 1
end

function loading.draw()
	--os.execute("sleep .5")
	love.graphics.setColor(255,255,255,255)
	local str = "Loading: " .. loading.msg
	--print(str)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	
	love.graphics.setColor(150,150,150)
	love.graphics.setFont(fontSmall)
	love.graphics.print(str, Camera.scale*5, love.graphics.getHeight()-Camera.scale*8)
	
	love.graphics.setColor(44,90,160)
	love.graphics.setFont(fontLarge)
	love.graphics.printf(proverb, 0.2*w, 0.5*h, 0.6*w, 'center')
	
	local width, lines = fontLarge:getWrap(proverb, 0.6*w)
	
	love.graphics.setColor(150,150,150)
	love.graphics.setFont(fontSmall)
	love.graphics.printf(source, 0.5*w-0.5*width,0.5*h + lines * fontLarge:getHeight() * 1.25, width,'right')
end

function loading.preload()
-- This function does everything that is necessary before the loading 
-- screen can be shown: Set graphical mode and load font.
	Camera:init()	
	loadFont()	

	-- hide mouse
	love.mouse.setVisible(false)
	
	local proverbs = {
	{"Perseverence is strength",'Japanese Proverb'},
	{"Experience is the mother of wisdom",'Japanese Proverb'},
	{"If you do not enter the tiger's cave, you will not catch its cub.",'Japanese Proverb'},
	{"Fall down seven times, stand up eight",'Japanese Proverb'},
	{"The talented hawk hides its claws",'Japanese Proverb'},
	{"Don't follow proverbs blindly",'Go Proverb'},
	{"Big dragons never die",'Go Proverb'},
	{"Don't go fishing while your house is on fire",'Go Proverb'},
	}
	local nr = love.math.random(#proverbs)
	proverb = proverbs[nr][1]
	source = proverbs[nr][2]
	
	mode = 'loading'	
end

--[[ some proverbs:
----------------
Source: http://en.wikiquote.org/wiki/Japanese_proverbs

継続は力なり。
Keizoku wa chikara nari.
Translation: Perseverance is strength.

愚公山を移す
Translation: Faith can move mountains.

亀の甲より年の功
Translation: Experience is the mother of wisdom.

虎穴に入らずんば虎子を得ず。
Koketsu ni irazunba koji wo ezu.
Translation: If you do not enter the tiger's cave, you will not catch its cub.

七転び八起き Nana korobi ya oki
Translation: Fall down seven times, stand up eight

能ある鷹は爪を隠す。Nō aru taka wa tsume wo kakusu.
Translation: The talented hawk hides its claws

--------------
Source: http://senseis.xmp.net/?GoProverbs
Don't follow proverbs blindly
Big dragons never die
Don't go fishing while your house is on fire
--]]

return loading
