-- Lua script of map isle_of_storms/landing.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()

end)

function morus:on_interaction()
  game:start_dialog("_oakhaven.npcs.morus.ferry_2", function(answer)
    if answer == 1 then
      hero:teleport("oakhaven/port", "morus_landing")
    elseif answer == 2 then
      hero:teleport("snapmast_reef/snapmast_landing", "ferry_landing")
    elseif answer == 3 then
      game:start_dialog("_oakhaven.npcs.morus.ferry_already")
    end
  end)
end