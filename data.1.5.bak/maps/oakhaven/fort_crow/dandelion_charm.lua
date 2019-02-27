-- Lua script of map oakhaven/fort_crow/dandelion_charm.
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


function spirit:on_interaction()
  if game:get_value("have_dandelion_charm") ~= true then
    game:start_dialog("_goatshead.npcs.spirits.1", function()
      hero:start_treasure("dandelion_charm")
      game:set_value("have_dandelion_charm", true)
    end)

  else
    game:start_dialog("_goatshead.npcs.spirits.2")
  end
end