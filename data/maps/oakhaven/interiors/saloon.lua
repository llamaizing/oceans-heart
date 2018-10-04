-- Lua script of map oakhaven/interiors/saloon.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("salamander_heartache_storehouse_door_open") == true then map:open_doors("storehouse_door") end
  if game:has_item("sleeping_draught") == true then star_barrel:set_enabled(true) end
  if game:get_value("morus_available") ~= true then morus:set_enabled(false) end
end

function bartender:on_interaction()
  if game:get_value("morus_available") == true then
    if game:get_value("morus_counter") == nil then game:start_dialog("_oakhaven.npcs.saloon.bartender1")
    else game:start_dialog("_oakhaven.npcs.saloon.bartender2")
    end
  else --if Morus isn't around yet.
    game:start_dialog("_oakhaven.npcs.saloon.bartender2")
  end
end

function morus:on_interaction()
  if game:get_value("morus_counter") == nil then
    game:start_dialog("_oakhaven.npcs.morus.1", function()
      game:start_dialog("_game.quest_log_update")
      sol.audio.play_sound("quest_log")
      game:set_value("quest_log_b", "b5")
      game:set_value("looking_for_sleeping_potion", true)
    end)
    game:set_value("morus_counter", 1)

  elseif game:get_value("morus_counter") == 1 then
    game:start_dialog("_oakhaven.npcs.morus.2")

  elseif game:get_value("morus_counter") == 2 then
    game:start_dialog("_oakhaven.npcs.morus.3-spike_ale", function()
      game:set_value("quest_log_b", "b8")
      game:start_dialog("_game.quest_log_update")
      sol.audio.play_sound("quest_log")
      game:set_value("morus_counter", 3)
    end)

  elseif game:get_value("morus_counter") == 3 then
    game:start_dialog("_oakhaven.npcs.morus.4")

  elseif game:get_value("morus_counter") == 4 then
    game:start_dialog("_oakhaven.npcs.morus.5-gotofort")

  elseif game:get_value("morus_counter") == 5 then
    game:start_dialog("_oakhaven.npcs.morus.6", function()
      game:start_dialog("_game.quest_log_update")
      sol.audio.play_sound("quest_log")
      game:set_value("quest_log_b", "b11")
      game:set_value("morus_counter", 6)
      game:set_value("morus_available", false)
      game:set_value("morus_at_port", true)
    end)

  elseif game:get_value("morus_counter") == 6 then
    game:start_dialog("_oakhaven.npcs.morus.7")

  end
end

function storehouse_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("storehouse_door")
  game:set_value("salamander_heartache_storehouse_door_open", true)
end

function star_barrel_2:on_interaction()
  if game:get_value("morus_counter") == 3 then
    game:start_dialog("_oakhaven.observations.saloon.star_barrel_1", function(answer)
      if answer == 1 then
        game:start_dialog("_oakhaven.observations.saloon.star_barrel_2", function()
          game:start_dialog("_game.quest_log_update") sol.audio.play_sound("quest_log")
          game:set_value("quest_log_b", "b9")
          game:set_value("morus_counter", 4)
          game:set_value("spiked_crow_ale", true)
        end)--end of dialog 2 function end--end of if answer is 1
      end --end of if answer is
    end)--end of dialog 1 function
  end
end