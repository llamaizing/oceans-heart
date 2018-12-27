-- Lua script of map Yarrowmouth/caves/tern_marsh_ambush.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  map:set_doors_open("ambush_door")

end


function sensor:on_activated()
  if game:get_value("tern_ambush_sprung") ~= true then
    map:close_doors("ambush_door")
    game:start_dialog("_yarrowmouth.observations.ambush")
    game:set_value("tern_ambush_sprung", true)
  end
end

function marsh_ambush_enemy_1:on_dead()
  if map:get_entities_count("marsh_ambush_enemy") == 0 then
    map:open_doors("ambush_door")
    game:set_value("nina_dialog_counter", 2)
  end
end

function marsh_ambush_enemy_2:on_dead()
  if map:get_entities_count("marsh_ambush_enemy") == 0 then
    map:open_doors("ambush_door")
    game:set_value("nina_dialog_counter", 2)
  end
end

function marsh_ambush_enemy_3:on_dead()
  if map:get_entities_count("marsh_ambush_enemy") == 0 then
    map:open_doors("ambush_door")
    game:set_value("nina_dialog_counter", 2)
  end
end