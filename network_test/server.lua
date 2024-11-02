local net = require("networking")


if net.broadcast_message(123, 1, "MEOW", 1) then
  print("Successfuly sent a message :3")
else
  print("Failed to send a message or message not recieved")
end
