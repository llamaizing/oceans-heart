-- Lua script of map ballast_harbor/ballast_harbor.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()
local dropoff_workers_dialog_index = 1

map:register_event("on_started", function()
  if game:get_value("pirate_council_door_state") ~= nil then pirate_council_door:set_enabled(false) end
  if game:get_value("nina_dialog_counter") ~= nil and game:get_value("nina_dialog_counter") >= 3 then
    dream_cannon_guard:set_enabled(false)
  end
  if game:get_value("oakhaven_port_bridge_unblocked") then bomb_sale:set_enabed(false) end
  if game:get_value("talked_to_hornigold_in_ballast_harbor") then
    hornigold:set_enabled(false)
    hornigold_sensor:set_enabled(false)
  end
  --Ship dropping off stuff for Pirate Vault
  if game:get_value("ballast_harbor_dropoff_guys_in_port") then
    for entity in map:get_entities("dropoff_") do
      entity:set_enabled(true)
      inviting_barrel:set_enabled(true)
    end
  end

end)



---NPC INTERACTIONS
--cargo carrier guys:
for npc in map:get_entities("dropoff_npc") do
  function npc:on_interaction()
    if dropoff_workers_dialog_index == 1 then
      game:start_dialog("_ballast_harbor.npcs.dropoff_guys.2")
    elseif dropoff_workers_dialog_index == 2 then
      game:start_dialog("_ballast_harbor.npcs.dropoff_guys.3")
    elseif dropoff_workers_dialog_index == 3 then
      game:start_dialog("_ballast_harbor.npcs.dropoff_guys.1")
    end
    dropoff_workers_dialog_index = dropoff_workers_dialog_index + 1
    if dropoff_workers_dialog_index == 4 then dropoff_workers_dialog_index = 1 end
  end  
end

--inviting barrel
function inviting_barrel:on_interaction()
  game:start_dialog("_ballast_harbor.observations.inviting_barrel", function(answer)
    if answer == 2 then
      hero:teleport("ballast_harbor/pirate_vault", "from_smuggled_in")
print("there's no dungeon to be teleported to yet!")
      game:set_value("ballast_harbor_dropoff_guys_in_port", false)
    end
  end)
end



---------Cutscene-----------
function hornigold_sensor:on_activated()
  hero:freeze()
  local m1 = sol.movement.create("path")
  m1:set_path{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
  m1:set_speed(60)
  m1:set_ignore_obstacles(true)
  m1:start(hornigold, function()
    game:start_dialog("_ballast_harbor.npcs.hornigold.1", function()
      m1:set_speed(70)
      m1:set_path{4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6}
      hero:set_direction(3)
      m1:start(hornigold, function()
        game:set_value("talked_to_hornigold_in_ballast_harbor", true)
        hero:unfreeze()
        hornigold:set_enabled(false)
        hornigold_sensor:set_enabled(false)
      end)
    end) --end of dialog callback
  end) --end of m1 callback
end



---------THESE GUYS WILL ALL PROBABLY EVENTUALLY BE DELETED:

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
          hero:start_treasure("arrow", 2)
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