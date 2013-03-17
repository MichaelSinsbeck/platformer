platformer
==========

This is a platformer I am currently working on. It is written in love2d.
For running first install löve2d (google it)
Then go to this folder and run "love ."

Workplan:
- implement multiple levels

- add animation

- Add movement-features
 x wall jump
 x double jump
 x glide
 - rope        ->postponed
 - bungee rope ->postponed
 
- Add enemies
 - Spikes
 - ?
 
- Add interative objects
 - Fan
 - Bounce-platform
 
- Engine Stuff
 X Solve 0.99-Problem for collision
 X Add Sprite Engine
 - Clean up player-movement
 - Write generic collision test
 X Generalize controls -> Pass keypressed to spriteEngine
 X To test: Do walls stick, if jumped to from below?
 
Reminder for me:
To produce a level:
- Draw in Tiled
- Open in Texteditor
- Copy to main.lua in Leveleditor
- Run leveleditor
- mapfile is finished in hidden folder
