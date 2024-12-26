local navigation = require("navigation")
local networking = require("networking")
local component = require("component")
local sides = require("sides")
local robot = require("robot")

-- The state of the apiary (on/off)
local apiary_state = false

-- Port on which to receive messages
local port = 1234

-- The range in which to search for waypoints
local waypoint_range = 128
-- The direction, the robot must face to interact with the apiary block
local apiary_direction = sides.south


local function toggle_apiary()
  -- Disable the apiary
  navigation.go_to_waypoint("apiary_switch", waypoint_range)
  component.redstone.setOutput(sides.down, 15)
  --wait a second
  os.sleep(1)
  component.redstone.setOutput(sides.down, 0)
end

local function go_home()
  navigation.go_to_waypoint("home", waypoint_range)
end

local function check_screwdriver()
  -- kinda scuffed, but it works
  local _, m = robot.durability()
  if m == "tool cannot be damaged" then
    -- The screwdriver still has some uses in it
    return;
  end
  -- The screwdriver is broken, need to get a new one
  navigation.go_to_waypoint("screwdriver", waypoint_range)
  -- Get a screwdriver
  component.inventory_controller.suckFromSlot(sides.down, 2, 1)
  -- Equip it
  component.inventory_controller.equip()
end

local function switch_apiary_mode()
  navigation.go_to_waypoint("apiary", waypoint_range)
  navigation.rotate_to(apiary_direction)

  robot.use()
  -- Check the screwdriver, just in case, bc it may have broken
  check_screwdriver()
end

local function switch_bees(bee)
  -- Go to the bee waypoint
  navigation.go_to_waypoint(bee, waypoint_range)

  local inv = component.inventory_controller


  local total_bees = 0
  -- Get everything from the bee chest
  while true do
    -- Suck until unable to
    if not inv.suckFromSlot(sides.down, 2, 1) then
      break
    end
    total_bees = total_bees + 1
  end

  -- Go to the bee drop off
  navigation.go_to_waypoint("bee_input", waypoint_range)

  for i = 1, total_bees, 1 do
    robot.select(i)
    -- alternate the slots just in case
    inv.dropIntoSlot(sides.down, (i % 4) + 1)
  end
  robot.select(1)
end


-- ensure that the robot is at home
go_home()

-- wait for a message from the server
while true do
  print("waiting for a message")
  local msg = networking.recieve_message(port)
  if msg == "STOP" then
    print("got a STOP command")
    if apiary_state then
      toggle_apiary()
      go_home()
    end
    apiary_state = false
  else
    -- Otherwise got the restocking command
    print("changing bees to", msg)
    -- First need to turn off the apiary
    if apiary_state then
      toggle_apiary()
      apiary_state = false
    end
    -- Switch apiary mode to output, assume that the apiary mode is operational
    switch_apiary_mode()
    switch_apiary_mode()

    -- Switch the apiary back on
    toggle_apiary()

    -- Disable it again
    toggle_apiary()

    -- Switch to input mode
    switch_apiary_mode()
    switch_apiary_mode()

    -- Turn the apiary on
    toggle_apiary()
    -- just to avoid pathfinding issues
    go_home()
    -- Get bees
    switch_bees(msg)
    -- Disable it again
    toggle_apiary()

    -- Finally switch back to operating mode
    switch_apiary_mode()
    switch_apiary_mode()
    -- And turn the apiary on for the final time
    toggle_apiary()
    apiary_state = true

    go_home()
  end
end
