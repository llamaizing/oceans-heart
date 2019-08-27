local item = ...
local game = item:get_game()


function item:on_created()
  item:set_savegame_variable("possession_iron_pinecone")

end

function item:on_obtained()
  game:set_value("quest_iron_pine_cone", 1)
  game.objectives:refresh(self:get_savegame_variable())
end