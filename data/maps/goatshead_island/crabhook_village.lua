-- Lua script of map goatshead_island/crabhook_village.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

end

--Carrot Salesman
function salesman:on_interaction()
  game:start_dialog("_goatshead.npcs.crabhook.salesman", function(answer)
    if answer == 2 then
      if game:get_money() >= 5 then
        game:add_life(3)
        game:remove_money(5)
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end


function armor_sale:on_interaction()
  if game:get_value("crabhook_armor_purchased") == nil then
    game:start_dialog("_goatshead.npcs.crabhook.armor_saleslady.1", function(answer)
      if answer == 1 then
        map:get_hero():start_treasure("armor_upgrade_1")
        game:set_value("crabhook_armor_purchased", true)
        game:remove_money(150)
      end
    end)
  else
    game:start_dialog("_goatshead.npcs.crabhook.armor_saleslady.2")
  end
end


function fish_salesman:on_interaction()
  if game:get_value("phantom_squid_quest_completed") ~= true then
    game:start_dialog("_goatshead.npcs.crabhook.market_people.1")
  else
    game:start_dialog("_goatshead.npcs.crabhook.market_people.2")
  end
end

function old_fire_lady:on_interaction()
  if game:get_value("phantom_squid_quest_completed") ~= true then
    game:start_dialog("_goatshead.npcs.crabhook.market_people.3")
  else
    game:start_dialog("_goatshead.npcs.crabhook.market_people.4")
  end
end

--fisherman who tells you to talk to Arni
function fishin_guy:on_interaction()
  if game:get_value("looking_for_crabhook_monster") ~= true then
    game:start_dialog("_goatshead.npcs.crabhook.market_people.8")
    game:set_value("quest_crabhook_shoal_monster", 1) --quest log
    game:start_dialog("_game.quest_log_update")
  else
    if game:get_value("poplar_coast_menace_state") ~= nil then
      game:start_dialog("_goatshead.npcs.crabhook.market_people.10")
    else
      game:start_dialog("_goatshead.npcs.crabhook.market_people.9")
    end
  end
end