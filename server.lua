local sides = require("sides")
local component = require("component")
local computer = require("computer")

local inputs_1 = component.list("redstone")
local inputs = {}
-- Helper for finding redstone IO
print("Redstone io list:")
local j = 1
for i in inputs_1 do
  print(j, i)
  inputs[j] = i
  j = j + 1
end

table.sort(inputs)

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

local restocking_index = 0


local function start_restock(index)
  print(string.format("Out of %s", item_list[index][1]))
  computer.beep()
  component.modem.broadcast(port, item_list[index][1])
  restocking_index = index
end

-- Main loop
while true do
  -- Iterate over all the redstone IOs
  for _, i in pairs(inputs) do
    -- Skip redstone inputs that don't have an item assigned
    if item_list[i] == nil then
      goto continue
    end


    local redstone = component.proxy(i)

    -- if restocking, don't check the item
    if i == restocking_index then
      -- If the item has been restocked enough, stop restocking and go into checking mode
      if redstone.getInput(input_side) >= item_list[i][4] then
        print(string.format("Finished restocking %s", item_list[restocking_index][1]))
        restocking_index = 0
      else
        -- I hate how lua doesn't have fucking continue
        goto continue
      end
    end

    if redstone.getInput(input_side) < item_list[i][3] then
      -- If nothing is being restocked, start restocking
      if restocking_index == 0 then
        start_restock(i)
        -- check if the priority of the item is higher
      elseif item_list[i][2] > item_list[restocking_index][2] then
        start_restock(i)
      end
    end
    ::continue::
  end

  --Check again in a second
  os.sleep(1)
end
