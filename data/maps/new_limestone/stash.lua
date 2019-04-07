-- Lua script of map new_limestone/stash.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:set_doors_open("boss_door")
  if game:get_value("quest_whisky_for_juglan") and game:get_value("quest_whisky_for_juglan") < 1 then
    whisky:set_enabled(false)
  end
  if game:get_value("limestone_island_sea_hag_killed") then
    sea_hag:set_enabled(false)
    boss_sensor:set_enabled(false)
  end
end)

function whisky:on_interaction()
    game:set_value("quest_whisky_for_juglan_phase", 1) --quest log
    whisky:set_enabled(false)
    local i = 1
    for bridge in map:get_entities("collapsing_bridge") do
      sol.timer.start(map, i * 100, function()
        sol.audio.play_sound("wood_breaking_and_falling_into_water")
        bridge:set_enabled(false)
      end)
      i = i + 1
    end
    sol.timer.start(map, 1000, function()
        game:start_dialog("_new_limestone_island.observations.trapped_in_stash")
    end)
end


----switches-----
function a1_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("a1_door")
end

function b2_switch:on_activated()
  map:open_doors("b2_door")
end

function b2_switch:on_inactivated()
  map:close_doors("b2_door")
end


--sensor----
function boss_sensor:on_activated()
  map:close_doors("boss_door")
  game:start_dialog("_new_limestone_island.observations.sea_hag")
  boss_sensor:set_enabled(false)
end

function sea_hag:on_dead()
  map:open_doors("boss_door")
  game:set_value("limestone_island_sea_hag_killed", true)
end