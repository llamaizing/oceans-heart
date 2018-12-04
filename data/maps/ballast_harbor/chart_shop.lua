-- Lua script of map ballast_harbor/chart_shop.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

--movement to get kelpton out of the way
local m = sol.movement.create("path")
m:set_path{0,0}
m:set_speed(70)


-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:has_item("charts")==true then kelpton:set_enabled(false) else kelpton_2:set_enabled(false) end
  if game:get_value("talked_to_kelpton_2") == true and game:has_item("key_kingsdown")~= true then m:start(kelpton_2) end

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function kelpton:on_interaction()
  if game:get_value("have_ballast_harbor_clue") ~= true then
    game:start_dialog("_ballast_harbor.npcs.kelpton.0")
  elseif game:get_value("kelpton_convo_counter") == nil then
    game:start_dialog("_ballast_harbor.npcs.kelpton.1", function() game:start_dialog("_game.quest_log_update") sol.audio.play_sound("quest_log") end)
    game:set_value("quest_kelpton", 1) --quest log
    game:set_value("kelpton_convo_counter", 1)
  elseif game:get_value("kelpton_convo_counter") == 1 then
    game:start_dialog("_ballast_harbor.npcs.kelpton.2")

  end
end

function kelpton_2:on_interaction()
  if game:get_value("talked_to_kelpton_2") ~= true then
    --if you have the charts, and you've already spoken with Kelpton
    if game:get_value("kelpton_convo_counter") ~= nil then
      game:start_dialog("_ballast_harbor.npcs.kelpton.3", function()
        m:start(kelpton_2)
        game:start_dialog("_game.quest_log_update")
        sol.audio.play_sound("quest_log")
      end)
      game:set_value("talked_to_kelpton_2", true)
      game:set_value("quest_kelpton", 2) --quest log
    else --you haven't talked to kelpton, but you got the charts
      game:start_dialog("_ballast_harbor.npcs.kelpton.5", function() m:start(kelpton_2) end)
      game:set_value("talked_to_kelpton_2", true)
      game:set_value("quest_kelpton", 2) --quest log
    end
  else
    game:start_dialog("_ballast_harbor.npcs.kelpton.4")
  end
end