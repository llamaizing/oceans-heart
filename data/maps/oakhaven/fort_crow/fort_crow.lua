-- Lua script of map oakhaven/fort_crow/fort_crow.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  if not game:get_value("fort_crow_miniboss_defeated") then miniboss:set_enabled(true)
  else map:set_doors_open("b3_door")
  end

  --Alternating Steam Timer
  for steam in map:get_entities("alternating_steam_b") do steam:set_enabled(false) end
  sol.timer.start(map, 4000, function()
    sol.audio.play_sound("switch_2")
    for steam in map:get_entities("alternating_steam") do
      if steam:is_enabled() then steam:set_enabled(false)
      else steam:set_enabled(true) end
    end
  return true
  end)
end)



------Switches---------
function f5_switch:on_activated()
  map:open_doors("f5_door")
end

for switch in map:get_entities("a6_switch") do
function switch:on_activated()
  sol.audio.play_sound("switch")
  sol.audio.play_sound("steam_01")
  for steam in map:get_entities("a6_steam") do
    if steam:is_enabled() then steam:set_enabled(false)
    else steam:set_enabled(true) end
  end
  sol.timer.start(map, 200, function() switch:set_activated(false) end)
end
end

function e4_switch_a:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("e4_door_b")
end

function e4_switch_a:on_inactivated()
  sol.audio.play_sound("switch")
  map:close_doors("e4_door_b")
end

function e4_switch_b:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("e4_door_a")
end

function b4_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), a4_door, function() map:open_doors("a4_door") end)
end



-----Enemies-----------
for enemy in map:get_entities("a5_enemy") do
  function enemy:on_dead()
    if not map:has_entities("a5_enemy") then
      sol.audio.play_sound("secret")
      map:open_doors("a5_door")
    end
  end
end

function miniboss:on_dead()
  map:open_doors("b3_door")
end