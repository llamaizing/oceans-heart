-- Lua script of map stonefell_crossroads/sycamore_ferry.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local ferry_armed = false
function ferryman:on_interaction()
  local index = game:get_value("merryweather_ferry_dialog_index")
  if index == nil then
    game:start_dialog("_sycamore_ferry.npcs.ferryman.0")
    game:set_value("merryweather_ferry_dialog_index", 1)
    game:set_value("sycamore_ferry_unlocked", true)
  elseif index == 1 then
    game:start_dialog("_sycamore_ferry.npcs.ferryman.1")
  end
  ferry_armed = true
end

function ferry_south_sensor:on_activated()
  if game:get_value("sycamore_ferry_unlocked") or ferry_armed then
    sol.timer.start(map, 500, function()
      map:open_doors("ferry_south_gate")
      for entity in map:get_entities("ferry_north") do entity:remove() end
    end)
  end
end

function ferry_north_sensor:on_activated()
  sol.timer.start(map, 500, function()
    map:open_doors("ferry_north_gate")
    for entity in map:get_entities("ferry_south") do entity:remove() end
  end)
end

function right_knee:on_interaction()
  statue_door:set_enabled(false)
  sol.audio.play_sound"switch_2"
end

