-- Lua script of map new_limestone/tavern_upstairs.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

function chair_sensor:on_activated()
  if game:get_value("limestone_room_is_messy_observation") == nil then
    game:start_dialog("_new_limestone_island.observations.linden_chair")
    game:set_value("limestone_room_is_messy_observation", true)
  end
end