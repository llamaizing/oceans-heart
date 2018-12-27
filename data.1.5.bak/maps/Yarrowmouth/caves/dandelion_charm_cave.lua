-- Lua script of map Yarrowmouth/caves/dandelion_charm_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  if game:get_value("have_dandelion_charm") == true and game:get_value("dandelion_charm_obtained") == nil then
      map:create_pickable({
        layer=0,
        x = 160, y = 128,
        treasure_name = "dandelion_charm",
        treasure_savegame_variable = "dandelion_charm_obtained"
      })
  end

end


function door_switch_1:on_activated()
  map:open_doors("shutter_door")
  print("switch_activated")
end

function spirit:on_interaction()
  if game:get_value("have_dandelion_charm") ~= true then
    game:start_dialog("_goatshead.npcs.spirits.1", function()
      map:create_pickable({
        layer=0,
        x = 160, y = 128,
        treasure_name = "dandelion_charm",
        treasure_savegame_variable = "dandelion_charm_obtained"
      })
      game:set_value("have_dandelion_charm", true)
    end)

  else
    game:start_dialog("_goatshead.npcs.spirits.2")
  end
end