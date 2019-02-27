-- Lua script of map oakhaven/interiors/apothecary.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("talked_to_aramis") == true then apothecary:set_enabled(false) else apothecary_2:set_enabled(false) end

end

function apothecary:on_interaction()
  --if you're not looking for the sleeping potion
  if game:get_value("looking_for_sleeping_potion") ~= true then
    game:start_dialog("_oakhaven.npcs.apothecary.1")

  else --you are looking for sleeping potion
    --and you don't already have the flowers:
    if game:has_item("monkshood") == false then
      game:start_dialog("_oakhaven.npcs.apothecary.2", function()
        game:start_dialog("_game.quest_log_update")
        game:set_value("quest_monkshood", 0) --quest log, start monkshood quest
        game:set_value("quest_log_b", "b6")
        game:set_value("talked_to_aramis", true)
        apothecary:set_enabled(false)
        apothecary_2:set_enabled(true)
      end) --end of dialog function

    else --if you alreadyhave monkshood when you go to talk to her
      game:start_dialog("_oakhaven.npcs.apothecary.2_already_have_monkshood", function()
        --map:create_pickable({ x=128, y=128, layer=0, treasure_name = "sleeping_draught"})
        hero:start_treasure("sleeping_draught", 1)
        game:set_value("quest_log_b", "b7") 
        game:set_value("quest_pirate_fort", 2) --quest log, finish monkshood quest
        game:set_value("quest_monkshood", 2) --quest log, back to morus
        game:set_value("talked_to_aramis", true)
        apothecary:set_enabled(false)
        apothecary_2:set_enabled(true)
        game:set_value("morus_counter", 2)
      end) --end of dialog function
    end
  end
end

function apothecary_2:on_interaction() --for once you've talked to aramis once
  if game:has_item("sleeping_draught") == true then
    game:start_dialog("_oakhaven.npcs.apothecary.3-sleepwell")
  else -- don't have sleeping draught yet
    if game:has_item("monkshood") == false then
      game:start_dialog("_oakhaven.npcs.apothecary.4-look_for_monskhood")
    else --if you do have monkshood
      game:start_dialog("_oakhaven.npcs.apothecary.5-return_with_poison", function()
        --map:create_pickable({ x=128, y=128, layer=0, treasure_name = "sleeping_draught"})
        hero:start_treasure("sleeping_draught", 1, "", function()
          game:set_value("quest_log_b", "b7")
          game:start_dialog("_game.quest_log_update")
          game:set_value("quest_monkshood", 2) --finish monkshood quest
          game:set_value("quest_pirate_fort", 2) --quest log, back to morus
          game:set_value("morus_counter", 2)
        end)

      end) --end of dialog function
    end --end of if have monkshood
  end --end of if have sleeping draught
end



function elixer_seller:on_interaction()
  game:start_dialog("_goatshead.npcs.crabhook.witch_pot", function(answer)
    if answer == 3 then
      if game:has_item("kingscrown") == true
      and game:has_item("ghost_orchid") == true and game:has_item("mandrake_white") == true and game:get_money() >= 25 then
        --map:create_pickable({ layer = 0, x = 136, y = 136, treasure_name = "elixer", })
        hero:start_treasure("elixer", 1)
        game:remove_money(25)
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
  end)
end