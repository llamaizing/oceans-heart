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
  map:open_doors("front_door")
end

function hub_room_door_switch:on_activated()
  map:get_camera():shake({count = 8, amplitude = 4, speed = 80})
  map:open_doors("hub_room_door")
end

function d4_door_switch:on_activated()
  map:open_doors("room_d4_door")
end

function d1_door_switch:on_activated()
  map:open_doors("d1_door")
end




------End treasure chest--------
function warp_to_start_sensor:on_activated()
  if game:has_item("charts") then
    hero:teleport("ballast_harbor/ballast_harbor", "from_pirate_building_upstairs")
  end
end


