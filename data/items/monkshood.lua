local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_monkshood")
  item:set_amount_savegame_variable("amount_monkshood")
end

function item:on_obtained()
  self:add_amount(1)
  if game:get_value("quest_monkshood") then game:set_value("quest_monkshood", 1) end
end

-- Event called when a pickable treasure representing this item
-- is created on the map.
-- You can set a particular movement here if you don't like the default one.
function item:on_pickable_created(pickable)


end