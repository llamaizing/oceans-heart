local item = ...
local game = item:get_game()

function item:on_created()
  item:set_savegame_variable("possession_hideout_chart")

end


function item:on_pickable_created(pickable)

end