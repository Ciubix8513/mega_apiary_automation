local shell = require("shell")

local repo = "https://raw.githubusercontent.com/ciubix8513/mega_apiary_automation/"

shell.execute(string.format("wget $s/networking.lua", repo))
shell.execute(string.format("wget $s/server.lua", repo))
shell.execute(string.format("wget $s/item_list.lua", repo))