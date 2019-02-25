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


end)

function b7_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), b7_door, function() map:open_doors("b7_door") end)
end