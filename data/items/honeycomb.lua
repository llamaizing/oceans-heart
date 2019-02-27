local item = ...
local game = item:get_game()


function item:on_created()
  item:set_savegame_variable("possession_honeycomb")
end

function item:on_obtained()
  if game:get_value("quest_ballast_harbor_hornet_honey") == 0 then
    game:set_value("quest_ballast_harbor_hornet_honey", 1)
  end
end