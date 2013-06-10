platformer
==========

This is a platformer I am currently working on. It is written in LÖVE.
For running first install LÖVE  (www.love2d.org)
Then go to this folder and run "love ."

Workplan:

- Content
 - Add bandana items (red, blue, green, yellow)
 - Add carrying ability
 - Add hiding ability
 - Add movable objects, the player can stand on
 - Draw red blocks similar to ground tiles (16 tiles)
 
- Engine stuff
 - Add menu
 - remove dynamic line of sight of cannons, create a table in the first place
 - Set up clever system for collision checks between objects -> Read on spacial hashing
 - Own level editor
 - [improve] flexible resolution setting (render images in high resolution, scale down)

- Add enemies
 - Walking block
 - "cannon" with fixed angle and fixed fire rate
 
- Interactive Objects
 - Buttons and doors
 - Fan (special interaction with blue bandana)

- Global variables (need to clean up):
 - initAll
 - gravity
 - p/myMap


--- old stuff ---


- Level loading stuff:
 - [postponed] create zones (level editor)
 - [postponed] write loading function that runs in bg
 - [done] load levels
 - [done] integrated enemy placement into level file

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
