local item = ...
local game = item:get_game()


function item:on_started()
  item:set_savegame_variable("found_heron_door_snapmast")
end
