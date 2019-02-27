-- Lua script of map oakhaven/fort_crow/courtyard.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  if game:get_value("fort_crow_furnace_lit") == true then tower_door:set_enabled(false) end
  if game:get_value("fort_crow_furnace_r") == true then
    for entity in map:get_entities("tower_door_steam_b") do entity:set_enabled(true) end
  end
  if game:get_value("fort_crow_furnace_l") == true then
    for entity in map:get_entities("tower_door_steam_a") do entity:set_enabled(true) end
  end
  if game:get_value("thyme_defeated") == true then
    for pirate in map:get_entities("sleeping_pirate") do pirate:set_enabled(false) end
  end

--steam timer
  for steam in map:get_entities("steam_b") do steam:set_enabled(false) end

  sol.timer.start(map, 4000, function()
    sol.audio.play_sound("switch_3")
    sol.audio.play_sound("steam_01")
    for steam in map:get_entities("steam") do
      if steam:is_enabled() == true then steam:set_enabled(false)
      else steam:set_enabled(true)
      end
    end
    return true
  end) --end of 4 sec timer a.

end



function switch_steam_1:on_activated()
  for steam in map:get_entities("blocking_steam_b") do
    steam:set_enabled(false)
    sol.timer.start(3800, function()
      steam:set_enabled(true)
      switch_steam_1:set_activated(false)
      sol.audio.play_sound("switch")
    end)
  end
end