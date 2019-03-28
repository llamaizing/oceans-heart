-- Lua script of map oakhaven/fort_crow/fort_crow.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local need_to_be_insibible = false

map:register_event("on_started", function()
  map:set_doors_open("boss_door")
  if not game:get_value("fort_crow_miniboss_defeated") then miniboss:set_enabled(true)
  else map:set_doors_open("b3_door")
  end
  if game:get_value("fort_crow_interior_morus_counter") == 1 then morus_1:set_enabled(true) end
  if game:get_value("fort_crow_interior_morus_counter") == 2 then morus_2:set_enabled(true) end
  if game:get_value("fort_crow_interior_morus_counter") == 3 then morus_3:set_enabled(true) end
  if game:get_value("fort_crow_interior_morus_counter") == 4 then morus_4:set_enabled(true) end

  --Alternating Steam Timer
  for steam in map:get_entities("alternating_steam_b") do steam:set_enabled(false) end
  sol.timer.start(map, 4000, function()
    sol.audio.play_sound("click_low")
    for steam in map:get_entities("alternating_steam") do
      if steam:is_enabled() then steam:set_enabled(false)
      else steam:set_enabled(true) end
    end
  return true
  end)

  --Robot Part Spawners
  for spawner in map:get_entities("robot_part_spawner") do
    local x, y, layer = spawner:get_position()
    sol.timer.start(map, 2000, function() map:spawn_robot_part(x, y, layer, 0) return true end)
  end

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

function e1_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("e1_door")
  game:start_dialog("_oakhaven.npcs.morus.fort.5", function()
    local m = sol.movement.create("path")
    m:set_path{2,2,2,2,2,2,2,2}
    m:start(morus_3, function() morus_3:set_enabled(false) end)
    game:set_value("fort_crow_interior_morus_counter", 4)
  end)
end

function d1_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("d1_door")
end

--pre-miniboss switch
function f3_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("c4_door")
  game:start_dialog("_oakhaven.npcs.morus.fort.4")
  morus_2:set_enabled(false)
  morus_3:set_enabled(true)
end



-----Sensors----------
function boss_sensor:on_activated()
  jazari_dummy:set_enabled(false)
  jazari_boss:set_enabled(true)
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



-------Robot Parts------------
function map:spawn_robot_part(x, y, layer, direction)
  local bot_part = map:create_stream({
    x = x+8, y = y+11, layer = layer, direction = direction,
    sprite = "entities/robot_parts", speed = 96,
  })
  bot_part:set_drawn_in_y_order(true)
  local m = sol.movement.create("straight")
  m:set_angle(direction * math.pi / 2)
  m:start(bot_part, function() bot_part:remove() end)
  function m:on_obstacle_reached() bot_part:remove() end
end



--------Morus'es------------
function morus_1:on_interaction()
  game:start_dialog("_oakhaven.npcs.morus.fort.2", function()
    local m = sol.movement.create("path")
    m:set_speed(80)
    m:set_path{2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
    m:start(morus_1, function() morus_1:remove() end)
    game:set_value("fort_crow_interior_morus_counter", 2)
    morus_2:set_enabled(true)
  end)
end