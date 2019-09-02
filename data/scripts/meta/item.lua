-- Initialize equipment item behavior specific to this quest.

require"scripts/multi_events"

local item_meta = sol.main.get_metatable"item"

--trigger quest log update when an item is obtained
item_meta:register_event("on_obtained", function(self)
  local savegame_variable = self:get_savegame_variable()
  if savegame_variable then
    local game = self:get_game()
    game.objectives:refresh(savegame_variable)
  end
end)


return true
