local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()
  item:set_savegame_variable("possession_stone_beak")

end

function item:on_obtained()
  game:set_value("quest_stone_beak", 0)
end