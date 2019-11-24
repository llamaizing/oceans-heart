-- Lua script of map ballast_harbor/ballast_harbor.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if hero:get_position() == from_back_alley_cave:get_position() then
    destroyable_fence:set_enabled(false)
  end
end)
