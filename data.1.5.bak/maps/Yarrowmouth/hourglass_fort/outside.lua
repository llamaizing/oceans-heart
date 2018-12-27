-- Lua script of map Yarrowmouth/hourglass_fort/outside.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("hourglass_fort_read_letter") == true then eudicot:set_enabled(false) end

end



function bridge_switch_1:on_activated()
  map:open_doors("central_door")
end

function talk_sensor:on_activated()
  if game:get_value("hourglass_fort_observation_made_1") ~= true then
    game:start_dialog("_yarrowmouth.observations.hourglass_fort.nobody_home")
    game:set_value("hourglass_fort_observation_made_1", true)
  end  
end