local net = require("networking")

while true do
  local msg = net.recieve_message(1)
  if msg == nil then
    print("Failed to recieve a message")
  else
    print(string.format("Recieved message %s", msg))
  end
end
