local item = ...
local game = item:get_game()


function item:on_created()
  item:set_savegame_variable("possession_key_juneberry_inn")
  item:set_amount_savegame_variable("amount_key_juneberry_inn")
end

function item:on_obtained()
  self:add_amount(1)

end