-- Lua script of map new_limestone/limestone_present.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:has_item("sword") == true then sword_chest:set_enabled(false) end
  to_goatshead:set_enabled(false)
  

end


function juglan:on_interaction()
  -- first time leaving
  if game:get_value("left_limestone") == nil then
    game:start_dialog("_new_limestone_island.npcs.juglan.first_time_leaving", function(answer)
      if answer == 2 then
        game:start_dialog("_new_limestone_island.npcs.juglan.first_time_leaving_confirm", function()
          to_goatshead:set_enabled(true)
          game:set_value("left_limestone", true)

        end)
      end
    end)
  -- have left Limestone before
  else
    game:start_dialog("_new_limestone_island.npcs.juglan.travel_to_goatshead", function(answer)
      if answer == 2 then
        to_goatshead:set_enabled(true)
      end
      end)
       
  end
end