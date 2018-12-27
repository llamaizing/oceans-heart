-- Lua script of map goatshead_island/interiors/CV_witch.
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

function witch:on_interaction()
  game:start_dialog("_goatshead.npcs.crabhook.witch", function(answer)
    if answer == 3 then
      if game:get_money() >= 100 then
        map:create_pickable({
          layer = 0, x = 136, y = 136,
          treasure_name = "elixer",
        })
        game:remove_money(100)
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end

function pot:on_interaction()
  game:start_dialog("_goatshead.npcs.crabhook.witch_pot", function(answer)
    if answer == 3 then
      if game:has_item("kingscrown") == true
      and game:has_item("ghost_orchid") == true and game:has_item("mandrake_white") == true and game:get_money() >= 25 then
        map:create_pickable({
          layer = 0, x = 136, y = 136,
          treasure_name = "elixer",
        })
        game:remove_money(25)
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
  end)
end