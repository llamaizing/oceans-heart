-- Lua script of map goatshead_island/interiors/flower_shop.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


function atem:on_interaction()
  game:start_dialog("_goatshead.npcs.flower_shop.1")
end
