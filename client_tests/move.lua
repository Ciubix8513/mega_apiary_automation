local navigation = require("navigation")
local move_to = navigation.move_to

local pos = { 10, 10, 10 }
move_to(pos)

local pos = { -10, -10, -10 }
move_to(pos)

local pos = { 10, 0, 0 }
move_to(pos)

local pos = { -10, 0, 0 }
move_to(pos)

local pos = { 0, 10, 0 }
move_to(pos)

local pos = { 0, -10, 0 }
move_to(pos)

local pos = { 0, 0, 10 }
move_to(pos)

local pos = { 0, 0, -10 }
move_to(pos)
