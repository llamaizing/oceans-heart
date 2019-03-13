-- Lua script of map goatshead_island/caves/brickabranch_shrine.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  boss:set_damage(3)
end)

function boss:on_dead()
  map:open_doors("boss_door")
end