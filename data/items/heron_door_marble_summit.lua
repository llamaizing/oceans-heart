local item = ...
local game = item:get_game()


function item:on_started()
  item:set_savegame_variable("possession_heron_door_marble_summit")
end
