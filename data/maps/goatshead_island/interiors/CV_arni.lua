-- Lua script of map goatshead_island/interiors/CV_arni.
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

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function arni:on_interaction()
  if game:get_value("talked_to_arni") ~= true then
    if game:get_value("looking_for_crabhook_monster") == nil then
      game:start_dialog("_goatshead.npcs.crabhook.arni.1")
    else
      game:start_dialog("_goatshead.npcs.crabhook.arni.2", function()
        game:set_value("talked_to_arni", true)
        game:set_value("quest_crabhook_shoal_monster", 2) --quest log
        game:start_dialog("_game.quest_log_update")
      end)
    end
  else
    game:start_dialog("_goatshead.npcs.crabhook.arni.3")
  end
end