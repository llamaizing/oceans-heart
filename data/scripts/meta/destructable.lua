local destructible_meta = sol.main.get_metatable("destructible")

function destructible_meta:on_created()
  self:set_drawn_in_y_order(true)
end
