-- Lua script of map snapmast_reef/landing.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  local world = map:get_world()
  game:set_world_rain_mode(world, "storm")
  if game:get_value("quest_snapmast") == 0 then game:set_value("quest_snapmast", 1) end

end)

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function morus:on_interaction()
  if game:has_item("oceansheart_chart") == true then

  else
    game:start_dialog("_oakhaven.npcs.morus.ferry_1_reef", function(answer)
      if answer == 2 then
        hero:teleport("oakhaven/port", "morus_landing")
      end
    end)
  end
end