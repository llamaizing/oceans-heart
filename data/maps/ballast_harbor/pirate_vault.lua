-- Lua script of map ballast_harbor/pirate_vault.
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



-----------------------SWITCHES----------------------------

function front_door_switch:on_activated()
  map:open_doors("front_door")
end

