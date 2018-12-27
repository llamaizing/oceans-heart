-- Lua script of map oakhaven/eastoak.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  guard_2:set_enabled(false)
  if game:get_value("spiked_crow_ale") then guard_1:set_enabled(false) guard_2:set_enabled(true) end
  if game:get_value("fort_crow_front_door_open") == true then map:set_doors_open("front_door") end
  if game:get_value("thyme_defeated") == true then guard_2:set_enabled(false) boat:set_enabled(false) boat_2:set_enabled(false) end
end