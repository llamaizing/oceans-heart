local item = ...
local game = item:get_game()


function item:on_created()
  item:set_savegame_variable("possession_iron_pinecone")

end