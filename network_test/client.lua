net = require("networking")

while true do
  local msg = net.recieve_msg(1)
  if msg == nil then
    print("Failed to recieve a messagw")
  else
    print(string.format("Recieved message %s", msg))
  end
end
