local sides = require("sides")
local component = require("component")
local computer = require("computer")
local inputs_1 = component.list("redstone")
local inputs = {}

-- Helper for finding redstone IO
print("Redstone io list:")
local j = 1
for i in inputs_1 do
  print(i)
  inputs[j] = i
  j = j + 1
end

-- Server configuration
local item_list = {
  -- Item name, priority, lower redstone signal threshold, upper RST
  [inputs[1]] = { "redstone", 0, 2, 14 },
  [inputs[2]] = { "xenon", 2, 2, 14 },
  [inputs[3]] = { "cobalt", 10, 2, 14 },
  [inputs[4]] = { "helium", 1, 1, 12 },
}
-- Side on which redstone IO receives input
local input_side = sides.north
-- Port for communicating with the robot
local port = 1234

-- Main loop
while true do
  -- Iterate over all the redstone IOs
  for _, i in pairs(inputs) do
    redstone = component.proxy(i)

    if redstone.getInput(input_side) < 5 then
      print(string.format("Out of %s", item_list[i][1]))
      computer.beep()

      component.modem.broadcast(port, item_list[i][1])
    end
  end
  --Check again in a second
  os.sleep(1)
end
