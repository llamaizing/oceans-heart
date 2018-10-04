-- Lua script of map ballast_harbor/honestbeard.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local item_lander_x = 152
local item_lander_y = 128

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("honestbeard_coral") == true then coral_ore_icon:set_enabled(false) end

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

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

--buy coral ore
function coral_ore_sale:on_interaction()
  if game:get_value("honestbeard_coral") ~= true then
    game:start_dialog("_ballast_harbor.npcs.honestbeard.coral_ore", function(answer)
      if answer == 1 then
        if game:get_money() >= 120 then
          map:create_pickable({
            layer = 0, x = item_lander_x, y = item_lander_y,
            treasure_name = "coral_ore",
          })
          game:remove_money(120)
          game:set_value("honestbeard_coral", true)
          coral_ore_icon:set_enabled(false)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end)
  else
  game:start_dialog("_ballast_harbor.npcs.honestbeard.out_of_coral")
  end
end

--buy armor
function armor_sale:on_interaction()
  if game:get_value("honestbeard_armor") ~= true then
    game:start_dialog("_ballast_harbor.npcs.honestbeard.armor", function(answer)
      if answer == 3 then
        if game:get_money() >= 150 then
          map:create_pickable({
            layer = 0, x = item_lander_x, y = item_lander_y,
            treasure_name = "armor_upgrade_2",
          })
          game:remove_money(150)
          game:set_value("honestbeard_armor", true)
          armor_icon:set_enabled(false)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end)
  else
  game:start_dialog("_ballast_harbor.npcs.honestbeard.out_of_coral")
  end
end