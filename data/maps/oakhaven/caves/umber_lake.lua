-- Lua script of map oakhaven/caves/umber_lake.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function coral_boss:on_dead()
  map:open_doors("coral_ore_door")
end