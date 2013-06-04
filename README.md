platformer
==========

This is a platformer I am currently working on. It is written in LÖVE.
For running first install LÖVE  (www.love2d.org)
Then go to this folder and run "love ."

Workplan:
- Level loading stuff:
 - create zones (level editor)             ->postponed
 - write loading function that runs in bg  ->postponed
 x load levels
 x integrated enemy placement into level file

- own level editor

- menu

x add animation system
 - complete animations for player

- Add movement-features
 x wall jump
 x double jump
 x glide
 - rope        ->postponed
 - bungee rope ->postponed
 - Fix Bug: When jumping from wall, higher velocity are possible: shouldn't be
 - disable sticky walls, if wall jump is disabled (?)
 - gliding with "jump"-button? Reserve second button for something else?
 
- Add enemies
 x Spikes
 x Walking block
 x Runner
 x Goalie
 x cannon
 x missile launcher
 - "cannon" with fixed angle and fixed fire rate
 
- Add interative objects
 - Fan
 x Bounce-platform
 x one-way platform
 
- Engine Stuff
 X Solve 0.99-Problem for collision
 X Add Sprite Engine
 x Clean up player-movement
 X Write generic collision test
 X Generalize controls -> Pass keypressed to spriteEngine
 X To test: Do walls stick, if jumped to from below?
 
Reminder for me:
To produce a level:
- Draw in Tiled
- Run love-project in levelconverter/
- copy all *.dat from ./local/share/love/levelconverter/ to current folder



Global variables (need to clean up):
verticalChange, tostring, gcinfo, os, imageHeight, getfenv, Spikey, pairs, 
mapSize, love, argv, tonumber, io, Campaign, spriteEngine, initAll, 
module, _G, imageWidth, intro, mode, coroutine, Map, Cannon, Animation, 
Launcher, loadstring, loadCollision, Bouncer, spriteFactory, string, 
xpcall, package, gravity, _VERSION, table, require, setmetatable, 
next, ipairs, Camera, rawequal, collectgarbage, game, getmetatable, 
p, lineOfSight, timer, debug, loadTiles, rawset, imageFilename, myMap, 
print, Runner, load, newproxy, math, menu, pcall, unpack, Explosion, 
type, Goalie, assert, select, Bullet, arg, rawget, Missile, Player, 
object, setfenv, start, dofile, error, loadfile
