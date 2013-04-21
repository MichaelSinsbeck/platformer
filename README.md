platformer
==========

This is a platformer I am currently working on. It is written in love2d.
For running first install löve2d (google it)
Then go to this folder and run "love ."

Workplan:
- Level loading stuff:
 - create zones (level editor)             ->postponed
 - write loading function that runs in bg  ->postponed
 x load levels
 x integrated enemy placement into level file

- add animation

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
 - Spikes
 - Walking block
 x Runner
 x Goalie
 - ?
 
- Add interative objects
 - Fan
 - Bounce-platform
 
- Engine Stuff
 X Solve 0.99-Problem for collision
 X Add Sprite Engine
 - Clean up player-movement
 X Write generic collision test
 X Generalize controls -> Pass keypressed to spriteEngine
 X To test: Do walls stick, if jumped to from below?
 
Reminder for me:
To produce a level:
- Draw in Tiled
- Run love-project in levelconverter/
- copy all *.dat from ./local/share/love/levelconverter/ to current folder
