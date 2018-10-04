-- Lua script of map goatshead_island/interiors/flower_shop.
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

function atem:on_interaction()
  game:start_dialog("_goatshead.npcs.flower_shop.1", function(answer)
    if answer == 2 then --sell 1
      if game:get_item("mandrake"):get_amount() >= 1 then
        game:get_item("mandrake"):remove_amount(1)
        game:add_money(15)
        game:start_dialog("_goatshead.npcs.flower_shop.2")
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
    if answer == 3 then --sell 5
      if game:get_item("mandrake"):get_amount() >= 10 then
        game:get_item("mandrake"):remove_amount(5)
        game:add_money(75)
        game:start_dialog("_goatshead.npcs.flower_shop.2")
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
  end)
end