local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_monster_eye")
  item:set_amount_savegame_variable("amount_monster_eye")
  item:set_brandish_when_picked(not game:has_item(item:get_name()))
end

function item:on_obtaining(variant, savegame_variable)
  if game:has_item(item:get_name()) then item:set_brandish_when_picked(false) end
  self:add_amount(1)
end


function item:on_pickable_created(pickable)


end