-- Tries to send a message, and waits for an acknowledgment from the other side
local function broadcast_message(src_port, dst_port, message, timeout)
  local component = require("component")
  local event = require("event")
  -- get the modem
  local modem = component.modem

  if modem == nil then
    -- No modem found returning false
    return false
  end

  -- Check if the src port is open, if it is, just quit
  if modem.isOpen(src_port) then
    return false
  end

  -- message structure:
  -- acknowledgment port, port on which to send the ACK msg

  local msg = string.pack("jxz", src_port, message)

  local retries = 3

  -- try to send the message a few times
  for _ = 1, retries, 1 do
    modem.broadcasat(dst_port, msg)
    modem.open(src_port)
    while true do
      local _, _, port, _, _, message = event.pull(timeout, "modem_message")
      if port == nil then
        break
      end

      if port == src_port then
        if message == "ACK" then
          return true
        else
          -- If didn't get an ACK msg, try again, probably not a good idea, but eh it's fiiiiine :3
          break
        end
      end
      modem.close(src_port)
    end
  end


  return false
end

local function recieve_message(port)
  local component = require("component")
  local event = require("event")

  local modem = component.modem

  if modem == nil then
    -- If didn't find a modem return nil
    return nil
  end

  -- Return nil if the port is already open
  if modem.isOpen(port) then
    return nil
  end

  modem.open(port)

  while true do
    local _, src, rcv_port, _, msg = event.pull("modem_message")

    -- if received a message on a different port, ignore it
    if port ~= rcv_port then
      goto continue
    end

    local dst_port, msg = string.unpack("jxz", msg)

    -- If the message is not properly formatted, wait for another one
    if dst_port == nil then goto continue end

    -- Send ACK msg
    if modem.send(src, dst_port, "ACK") then
      return msg
    end

    ::continue::
  end
end

return {
  broadcast_message = broadcast_message,
  recieve_message = recieve_message
}
