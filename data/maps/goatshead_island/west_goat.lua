-- Lua script of map goatshead_island/west_goat.
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

for ear in map:get_entities("goat_ear") do
  function ear:on_interaction()
    sol.audio.play_sound("switch_2")
    goat_snout_open:set_enabled(true)
    goat_snout_closed:set_enabled(false)
    goat_ear:set_enabled(false)
  end
end

function gerald:on_interaction()
  if game:get_value("west_goat_cracked_block_11") ~= nil then
    game:start_dialog("_goatshead.npcs.overworld.bomb_rocks_guy_2")
  else
    game:start_dialog("_goatshead.npcs.overworld.bomb_rocks_guy_1")
  end
end