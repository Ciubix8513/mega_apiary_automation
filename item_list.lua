local function gen_item_list(inputs)
  -- Edit this list to configure the inputs

  -- Item name,  priority, lower redstone threshold, upper redstone threshold
  return {
    [inputs[1]] = { name = "europium", priority = 2, l_rst = 2, u_rst = 14 },
    [inputs[2]] = { name = "xenon", priority = 4, l_rst = 2, u_rst = 14 },
    [inputs[3]] = { name = "ledox", priority = 5, l_rst = 2, u_rst = 14 }
  }
end

return { gen_item_list = gen_item_list }
