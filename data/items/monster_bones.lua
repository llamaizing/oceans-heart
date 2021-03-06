require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_monster_bones")
  item:set_amount_savegame_variable("amount_bones")
  item:set_brandish_when_picked(not game:has_item(item:get_name()))
end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)
  if game:has_item(item:get_name()) then item:set_brandish_when_picked(false) end
  local amounts = { 1, 3, 5}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'bones'")
  end
  self:add_amount(amount)
end)

-- Event called when a pickable treasure representing this item
-- is created on the map.
-- You can set a particular movement here if you don't like the default one.
item:register_event("on_pickable_created", function(self, pickable)

end)
