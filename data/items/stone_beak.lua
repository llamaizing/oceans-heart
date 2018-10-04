local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()
  item:set_savegame_variable("possession_stone_beak")

end