-- Lua script of map Yarrowmouth/interiors/shop.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local item_lander_x = 200
local item_lander_y = 120

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end



--buy bombs
function bomb_sale:on_interaction()
  game:start_dialog("_goatshead.npcs.alchemist.bombs", function(answer)
    if answer == 1 then
      if game:get_money() >= 50 then
        map:create_pickable({
          layer = 0, x = item_lander_x, y = item_lander_y,
          treasure_name = "bomb", treasure_variant = 3,
        })
        game:remove_money(50)
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end

function bomb_sale_2:on_interaction()
  game:start_dialog("_goatshead.npcs.alchemist.bombs", function(answer)
    if answer == 1 then
      if game:get_money() >= 50 then
        map:create_pickable({
          layer = 0, x = item_lander_x, y = item_lander_y,
          treasure_name = "bomb", treasure_variant = 3,
        })
        game:remove_money(50)
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end


--buy arrows
function arrow_sale:on_interaction()
  if game:has_item("bow") == true then
    game:start_dialog("_generic_dialogs.shop.arrows", function(answer)  
      if answer == 1 then
        if game:get_money() >= 10 then
          map:create_pickable({
            layer = 0, x = item_lander_x, y = item_lander_y,
            treasure_name = "arrow", treasure_variant = 2,
          })
          game:remove_money(10)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end)
  else --no bow
    game:start_dialog("_generic_dialogs.shop.arrows_no_bow")
  end
end

function arrow_sale_2:on_interaction()
  if game:has_item("bow") == true then
    game:start_dialog("_generic_dialogs.shop.arrows", function(answer)  
      if answer == 1 then
        if game:get_money() >= 10 then
          map:create_pickable({
            layer = 0, x = item_lander_x, y = item_lander_y,
            treasure_name = "arrow", treasure_variant = 2,
          })
          game:remove_money(10)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end)
  else --no bow
    game:start_dialog("_generic_dialogs.shop.arrows_no_bow")
  end
end



--buy an apple
function apple_sale:on_interaction()
  game:start_dialog("_shop.apple", function(answer)
    if answer == 3 then
      if game:get_money() >= 8 then
        game:add_life(4)
        game:remove_money(8)
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end