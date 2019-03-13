-- Lua script of map goatshead_island/brickabranch_island.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local switches_pressed

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "rain")
  switches_pressed = 0

end)

for switch in map:get_entities("door_switch") do
  function switch:on_activated()
    sol.audio.play_sound("switch")
    switches_pressed = switches_pressed + 1
    if switches_pressed >= 3 then
      map:focus_on(map:get_camera(), shrine_door, function()
        map:open_doors("shrine_door")
      end)
    end
  end
end