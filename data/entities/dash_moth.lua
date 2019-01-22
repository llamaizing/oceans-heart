local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Event called when the custom entity is initialized.
function entity:on_created()
  local m = sol.movement.create("random")
  m:start(entity)
  sol.timer.start(entity, 400, function() entity:remove() end)
end
