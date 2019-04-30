-- Lua script of map oakhaven/ivystump_interiors/crab_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  if game:get_value("quest_ivy_orchard") >= 3 then
    boss:set_enabled(false)
    map:set_doors_open("boss_door")
    for box in map:get_entities("apple_box") do box:set_enabled(true) end
  end
end


function boss:on_dead()
  map:open_doors("boss_door")
end

function paul:on_interaction()
  if game:get_value("quest_ivy_orchard") < 3 then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.4", function()
      game:set_value("quest_ivy_orchard", 3)
      game:add_money(120)
    end)
  else
    game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.5")
  end
end
