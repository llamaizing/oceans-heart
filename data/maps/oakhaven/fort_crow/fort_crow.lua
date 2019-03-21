-- Lua script of map oakhaven/fort_crow/fort_crow.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


map:register_event("on_started", function()

end)



------Switches---------
function f5_switch:on_activated()
  map:open_doors("f5_door")
end
