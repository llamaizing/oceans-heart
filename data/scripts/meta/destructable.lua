local destructible_meta = sol.main.get_metatable("destructible")

function destructible_meta:on_created()
  self:set_drawn_in_y_order(true)
  --as of Solarus 1.6, this code is ignored as destructibles are locked to 16x16:
  if self:get_name() == "philodendron_bush" then
    self:set_size(32,16)
  end
end
