-- Lua script of map ballast_harbor/pirate_vault.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()


end)



-----------------------SWITCHES----------------------------

function front_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("front_door")
end

function hub_room_door_switch:on_activated()
  sol.audio.play_sound("switch_2")
  map:get_camera():shake({count = 8, amplitude = 4, speed = 80})
  map:open_doors("hub_room_door")
end

function d4_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("room_d4_door")
end

function d1_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("d1_door")
end

function room_b2_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_b2")
end

function door_b4_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_b4")
end

for switch in map:get_entities("room_c8_switch") do
  local switches_activated = 0
  function switch:on_activated()
    sol.audio.play_sound("switch")
    for switch in map:get_entities("room_c8_switch") do
      if switch:is_activated() then switches_activated = switches_activated + 1 end
    end
    if switches_activated == 3 then
      map:focus_on(map:get_camera(), door_c8, function() map:open_doors("door_c8") end)
    end
  end
end

function door_c6_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_c6_switch")
end




--------Enemies----------------

for enemy in map:get_entities("a5_enemy") do
  function enemy:on_dead()
    if not map:has_entities("a5_enemy") then
      sol.audio.play_sound("secret")
      map:create_poof(a5_chest:get_position())
      a5_chest:set_enabled(true)
    end
  end
end

for enemy in map:get_entities("c1_enemy") do
  function enemy:on_dead()
    if not map:has_entities("c1_enemy") then
      map:open_doors("c1_door")
    end
  end
end





------End treasure chest--------
function warp_to_start_sensor:on_activated()
  if game:has_item("charts") then
    hero:teleport("ballast_harbor/ballast_harbor", "from_pirate_building_upstairs")
  end
end


