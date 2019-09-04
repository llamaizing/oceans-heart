-- Lua script of map new_limestone/sanctuary.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function ob_sensor:on_activated()
  if not game:get_value("limestone_seen_sanctuary_state") then
    game:start_dialog("_limestone_island.observations.sanctuary")
    game:set_value("limestone_seen_sanctuary_state", true)
    ob_sensor:remove()
  end
end