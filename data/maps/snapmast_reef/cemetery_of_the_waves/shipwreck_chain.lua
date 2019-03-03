-- Lua script of map snapmast_reef/cemetery_of_the_waves/shipwreck_chain.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain_inside")
  map:get_camera():letterbox()

end)

function b7_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), b7_door, function() map:open_doors("b7_door") end)
end

function d4_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), d4_door, function() map:open_doors("d4_door") end)
end

function c5_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), c5_door, function() map:open_doors("c5_door") end)
end

function door_a1_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_a1")
end