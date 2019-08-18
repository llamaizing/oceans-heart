local item = ...
local game = item:get_game()


function item:on_started()
  item:set_savegame_variable("possession_heron_door_snapmast_reef")
end
