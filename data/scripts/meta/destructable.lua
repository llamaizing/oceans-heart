local destructible_meta = sol.main.get_metatable("destructible")

function destructible_meta:on_created()
  self:set_drawn_in_y_order(true)
  --as of Solarus 1.6, this code is ignored as destructibles are locked to 16x16:
  if self:get_name() == "philodendron_bush" then
    self:set_size(32,16)
  end
end

local foraging_treasures = {
  "ghost_orchid",
  "firethorn_berries",
  "arrow",
  "apples",
  "kingscrown",
  "burdock",
  "chamomile",
  "berries",
  "lavendar",
  "witch_hazel"
}

destructible_meta:register_event("on_cut", function(self)
  local bush = self
  require("scripts/maps/foraging_manager"):process_cut_bush(bush)
end)