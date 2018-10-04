-- Lua script of map oakhaven/interiors/bomb_shop.
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

function bomb_maker:on_interaction()
  game:start_dialog("_oakhaven.npcs.shops.bomb_maker.1", function(answer)
    if answer == 2 then
      if game:get_item("firethorn_berries"):get_amount() >= 2 and game:get_money() >= 15 then
        game:remove_money(15)
        game:get_item("firethorn_berries"):remove_amount(2)
        map:create_pickable({
          x = 200, y = 136, layer = 0, treasure_name = "bomb", treasure_variant = 3, 
        })
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
  end)
end