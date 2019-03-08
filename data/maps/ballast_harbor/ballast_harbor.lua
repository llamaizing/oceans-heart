-- Lua script of map ballast_harbor/ballast_harbor.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()


map:register_event("on_started", function()
  if game:get_value("pirate_council_door_state") ~= nil then pirate_council_door:set_enabled(false) end
  if game:get_value("nina_dialog_counter") ~= nil and game:get_value("nina_dialog_counter") >= 3 then
    dream_cannon_guard:set_enabled(false)
  end
  if game:get_value("oakhaven_port_bridge_unblocked") then bomb_sale:set_enabed(false) end

end)



---NPC INTERACTIONS

--Bone buyer
function bone_buyer:on_interaction()
  game:start_dialog("_ballast_harbor.npcs.bone_buyer.1", function(answer)
    if answer == 2 then --sell 1
      if game:get_item("monster_bones"):get_amount() >= 1 then
        game:get_item("monster_bones"):remove_amount(1)
        game:add_money(10)
        game:start_dialog("_ballast_harbor.npcs.bone_buyer.2")
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
    if answer == 3 then --sell 10
      if game:get_item("monster_bones"):get_amount() >= 10 then
        game:get_item("monster_bones"):remove_amount(10)
        game:add_money(100)
        game:start_dialog("_ballast_harbor.npcs.bone_buyer.2")
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
  end)
end

--Guts Buyer
function guts_buyer:on_interaction()
  game:start_dialog("_ballast_harbor.npcs.guts_buyer.1", function(answer)
    if answer == 2 then --sell 1
      if game:get_item("monster_guts"):get_amount() >= 1 then
        game:get_item("monster_guts"):remove_amount(1)
        game:add_money(5)
        game:start_dialog("_ballast_harbor.npcs.guts_buyer.2")
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
    if answer == 3 then --sell 10
      if game:get_item("monster_guts"):get_amount() >= 10 then
        game:get_item("monster_guts"):remove_amount(10)
        game:add_money(50)
        game:start_dialog("_ballast_harbor.npcs.guts_buyer.2")
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
  end)
end


--buy bombs
function bomb_sale:on_interaction()
  game:start_dialog("_goatshead.npcs.alchemist.bombs", function(answer)
    if answer == 1 then
      if game:get_money() >= 50 then
        hero:start_treasure("bomb", 3)
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
            layer = 0, x = 152, y = 1336,
            treasure_name = "arrow", treasure_variant = 2,
          })
          game:remove_money(10)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end)
  else --no bow
    game:start_dialog("_ballast_harbor.npcs.market_people.arrows_no_bow")
  end
end

--Apple Salesman
function apple_salesman:on_interaction()
  game:start_dialog("_ballast_harbor.npcs.market_people.4", function(answer)
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