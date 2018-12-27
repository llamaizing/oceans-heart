local item = ...
local game = item:get_game()


function item:on_created()
  item:set_savegame_variable("possession_key_mead_safehouse")
  item:set_amount_savegame_variable("amount_key_mead_safehouse")
end

function item:on_obtained()
  self:add_amount(1)

end