
require("scripts/threadUtils")

local args = {...}

statusChannel = args[1]
printChannel = args[2] -- should be global!

print("worked!", "neat...")

print("abc")

statusChannel:push("success")
