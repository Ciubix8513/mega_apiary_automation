local component = require("component")
local sides = require("sides")
local robot = require("robot")

-- Pretty inefficient, but SHOULD work
local function rotate_to(target)
  while true do
    local facing = component.navigation.getFacing()
    if facing == target then
      return
    end
    robot.turnRight()
  end
end

local function move_to(pos)
  -- First move up
  if pos[2] >= 0 then
    for _ = 1, pos[2], 1 do
      robot.up()
    end
  end

  -- move in the x direction
  if pos[1] ~= 0 then
    if pos[1] >= 0 then
      rotate_to(sides.posx)
    else
      rotate_to(sides.negx)
    end

    for _ = 1, math.abs(pos[1]), 1 do
      robot.forward()
    end
  end

  -- move in the z direction
  if pos[3] ~= 0 then
    if pos[3] >= 0 then
      rotate_to(sides.posz)
    else
      rotate_to(sides.negz)
    end

    for _ = 1, math.abs(pos[3]), 1 do
      robot.forward()
    end
  end

  -- move down
  if pos[2] < 0 then
    for _ = 1, math.abs(pos[2]), 1 do
      robot.down()
    end
  end
end

local function go_to_waypoint(name, range)
  while true do
    local waypoints = component.navigation.findWaypoints(range)
    local target_pos = { 0, 0, 0 }

    for _, w in pairs(waypoints) do
      if w.label == name then
        target_pos = w.position
      end
    end

    -- loop until reached the end
    if target_pos[1] == 0 and target_pos[2] == 0 and target_pos[3] == 0 then
      return;
    end

    move_to(target_pos)
  end
end

return {
  rotate_to = rotate_to,
  move_to = move_to,
  go_to_waypoint = go_to_waypoint
}
