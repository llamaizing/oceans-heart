-- Lua script of map oakhaven/ivystump.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "birds")

end)



function picker_paul:on_interaction()
  if not game:get_value("quest_ivy_orchard") then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.1", function(answer)
      if answer == 3 then
        game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.2", function()
          game:set_value("quest_ivy_orchard", 0)
          for crab in map:get_entities("apple_boss") do crab:set_enabled() end
        end)
      end
    end)

  elseif game:get_value("quest_ivy_orchard") == 0 then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.3")

  elseif game:get_value("quest_ivy_orchard") == 1 then

  end

end


function picker_peter:on_interaction()
  if not game:get_value("quest_ivy_orchard") or game:get_value("quest_ivy_orchard") == 0 then

  elseif game:get_value("quest_ivy_orchard") == 1 then

  end
end
