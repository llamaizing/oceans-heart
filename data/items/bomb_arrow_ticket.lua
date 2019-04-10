local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()
  item:set_savegame_variable("possession_charts")
end


function item:on_obtained()
  game:set_value("quest_bomb_arrows", 0)
end