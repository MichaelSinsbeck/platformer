platformer
==========

This is a platformer I am currently working on. It is written in LÖVE.
For running first install LÖVE  (www.love2d.org)
Then go to this folder and run "love ."

Workplan:
- Level loading stuff:
 - [postponed] create zones (level editor)
 - [postponed] write loading function that runs in bg
 - [done] load levels
 - [done] integrated enemy placement into level file
 - remove dynamic line of sight of cannons, create a table in the first place
 - Add bandana items (red, blue, green, yellow)
 - Set up clever system for collision checks between objects
  - Read on spacial hashing
 - Add carrying ability
 - Add hiding ability
 - Add Objects, the player can stand on
 - Add buttons and doors

- own level editor

- menu

-  [done] add animation system
 - [done] complete animations for player

- Add movement-features
 - [done] wall jump
 - [done] double jump
 - [done] glide
 - [postponed] rope
 - [postponed] bungee rope
 - Fix Bug: When jumping from wall, higher velocity are possible: shouldn't be
 - disable sticky walls, if wall jump is disabled (?)
 - gliding with "jump"-button? Reserve second button for something else?
 
- Add enemies
 - [done] Spikes
 - Walking block
 - [done] Runner
 - [done] Goalie
 - [done] cannon
 - [done] missile launcher
 - "cannon" with fixed angle and fixed fire rate
 
- Add interative objects
 - Fan
 - [done] Bounce-platform
 - [done] one-way platform
 
- Engine Stuff
 - [done] Solve 0.99-Problem for collision
 - [done] Add Sprite Engine
 - [done] Clean up player-movement
 - [done] Write generic collision test
 - [done] Generalize controls -> Pass keypressed to spriteEngine
 - [done] To test: Do walls stick, if jumped to from below?
 
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
