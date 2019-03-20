-- Lua script of map oakhaven/caves/mangrove_tree.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function map:on_started()
  if game:has_item("sword_of_the_sea_king") then
    sword_tile:set_enabled(false)
    sword:set_enabled(false)
  else
    hazel:set_enabled()
  end
end


function sword:on_interaction()
  sword_tile:set_enabled(false)
  map:get_hero():start_treasure("sword_of_the_sea_king")
  sword:set_enabled(false)
end