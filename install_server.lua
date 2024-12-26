local shell = require("shell")

local repo = "https://raw.githubusercontent.com/ciubix8513/mega_apiary_automation/"
local branch = "master"

shell.execute(string.format("wget %s%s/networking.lua", repo, branch))
shell.execute(string.format("wget %s%s/server.lua", repo, branch))
shell.execute(string.format("wget %s%s/item_list.lua", repo, branch))
