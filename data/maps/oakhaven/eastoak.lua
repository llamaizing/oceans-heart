-- Lua script of map oakhaven/eastoak.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  guard_2:set_enabled(false)
  if game:get_value("spiked_crow_ale") then guard_1:set_enabled(false) guard_2:set_enabled(true) end
  if game:get_value("fort_crow_front_door_open") == true then map:set_doors_open("front_door") end
  if game:get_value("thyme_defeated") == true then guard_2:set_enabled(false) boat:set_enabled(false) boat_2:set_enabled(false) end

  local m1 = sol.movement.create("path")
  m1:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
    2,2,2,2,2,2,2,2,2,2,2}
  m1:set_speed(40)
  m1:set_ignore_obstacles(true)
  m1:start(circulate_guy)
  circulate_guy:set_traversable(true)
end)