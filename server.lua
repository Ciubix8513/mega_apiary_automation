local sides = require("sides")
local component = require("component")
local computer = require("computer")
local networking = require("networking")

local inputs_1 = component.list("redstone")
local inputs = {}

-- Helper for finding redstone IO
local j = 1

for i in inputs_1 do
  inputs[j] = i
  j = j + 1
end

table.sort(inputs)

print("Redstone io list:")
for i, a in pairs(inputs) do
  print(i, a)
end

-- Server configuration
local item_list = require("item_list").gen_item_list(inputs)

-- Side on which redstone IO receives input
local input_side = sides.north
-- Port for communicating with the robot
local port = 1234
local src_port = 88

local restocking_index = 0


local function start_restock(index)
  print(string.format("Out of %s", item_list[index].name))
  computer.beep()

  --The message has to be received, this way we can be sure that the robot got the request
  if networking.broadcast_message(src_port, port, item_list[index].name, 1) then
    restocking_index = index
  end
end

-- Disable the apiary
local function stop_restock()
  networking.broadcast_message(src_port, port, "STOP", 0.1)
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
      if redstone.getInput(input_side) >= item_list[i].u_rst then
        print(string.format("Finished restocking %s", item_list[restocking_index].name))
        restocking_index = 0
        stop_restock()
      else
        -- I hate how lua doesn't have fucking continue
        goto continue
      end
    end

    if redstone.getInput(input_side) <= item_list[i].l_rst then
      -- If nothing is being restocked, start restocking
      if restocking_index == 0 then
        start_restock(i)
        -- check if the priority of the item is higher
      elseif item_list[i].priority > item_list[restocking_index].priority then
        start_restock(i)
      end
    end

    ::continue::
  end

  --Check again in a second
  os.sleep(1)
end
