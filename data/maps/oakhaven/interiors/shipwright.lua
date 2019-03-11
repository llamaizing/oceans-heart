-- Lua script of map oakhaven/interiors/shipwright.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

end


function rope_switch:on_activated()
  local m1 = sol.movement.create("path")
  m1:set_path{4,4,4,4}
  local m2 = sol.movement.create("path")
  m2:set_path{4,4,4,4}
  m1:start(rope)
  m2:start(hook)
end
