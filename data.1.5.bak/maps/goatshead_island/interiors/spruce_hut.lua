-- Lua script of map goatshead_island/interiors/spruce_hut.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("talked_to_ilex_1") == true then ilex:set_enabled(false) end

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function ilex:on_interaction()
  if game:get_value("talked_to_ilex_1") ~= true then
    if game:get_value("have_spruce_clue") == true then
      game:start_dialog("_goatshead.npcs.ilex.1")
      game:set_value("talked_to_ilex_1", true)
    else
      game:start_dialog("_goatshead.npcs.ilex.0")
    end
  else
    game:start_dialog("_goatshead.npcs.ilex.2")
  end

end