local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_elixer")
  item:set_amount_savegame_variable("amount_elixer")
end

function item:on_obtained()
  self:add_amount(1)
print(game:get_value("amount_elixer"))
end