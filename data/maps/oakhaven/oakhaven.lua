-- Lua script of map oakhaven/oakhaven.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


--intro cutscene
function remember_sensor:on_activated()
  if game:get_value("hazel_is_here") ~= true then
    game:start_dialog("_generic_dialogs.hey")
    hero:freeze()
    hero:walk("2222210")
    sol.timer.start(map, 800, function()
      hero:unfreeze()
      game:start_dialog("_oakhaven.npcs.port.cervio.1", function()
        game:set_value("quest_hazel", 1) --quest log
        game:set_value("quest_log_a", "a9")
        game:set_value("hazel_is_here", true)
      end)
    end)
  end
end


-------------------------NPCS----------------------------

---Shops:
function blacksmith:on_interaction()
  blacksmith_funcs:open_shop(game)
end


function ferris:on_interaction()
  --if you haven't increased armor yet
  if game:get_value("ferris_armor_counter") == nil then

    game:start_dialog("_oakhaven.npcs.blacksmith.ferris.1", function(answer)
      if answer == 2 then
        if game:get_money() >= 100 then
          game:remove_money(100)
          game:start_dialog("_oakhaven.npcs.blacksmith.ferris.upgrade_armor")
          game:set_value("defense", game:get_value("defense") + 1)
          game:set_value("ferris_armor_counter", 1)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end) --end of dialog callback

  --if you've done one increase
  elseif game:get_value("ferris_armor_counter") == 1 then
    
    --if you do not have tools
    print(game:has_item("armor_tools"))
    if not game:has_item("armor_tools") then
      game:start_dialog("_oakhaven.npcs.blacksmith.ferris.2", function()
        game:set_value("quest_ferris_tools", 0) --quest log
      end)
    --if you HAVE the tools
    else
      game:start_dialog("_oakhaven.npcs.blacksmith.ferris.3", function(answer)
        game:set_value("quest_ferris_tools", 2) --quest log
        if answer == 2 then
          game:start_dialog("_oakhaven.npcs.blacksmith.ferris.upgrade_armor_2")
          game:set_value("defense", game:get_value("defense") + 2)
          game:set_value("ferris_armor_counter", 2)
        end
      end) --end of dialoge callback
    end
  elseif game:get_value("ferris_armor_counter") == 2 then
    game:start_dialog("_oakhaven.npcs.blacksmith.ferris.4")
  end --end of ferris_armor_counter
end