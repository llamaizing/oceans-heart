-- Lua script of map Yarrowmouth/caves/tern_marsh_ambush.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local trap_sprung

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  map:set_doors_open("ambush_door")
  trap_sprung = false
end


function sensor:on_activated()
  if game:get_value("tern_ambush_sprung") ~= true and trap_sprung == false then
    map:close_doors("ambush_door")
    game:start_dialog("_yarrowmouth.observations.ambush", function() game:set_value("quest_yarrow_parley", 1) end)
    trap_sprung = true
  end
end

for enemy in map:get_entities("marsh_ambush_enemy") do
  function enemy:on_dead()
    if map:get_entities_count("marsh_ambush_enemy") == 0 then
      game:set_value("tern_ambush_sprung", true)
      map:open_doors("ambush_door")
      game:set_value("nina_dialog_counter", 2)
      game:set_value("quest_yarrow_parley", 2) --quest log, go find Nina
    end
  end
end