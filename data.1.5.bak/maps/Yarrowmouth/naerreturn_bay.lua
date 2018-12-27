-- Lua script of map Yarrowmouth/naerreturn_bay.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("rohit_dialog_counter") ~= nil and game:get_value("rohit_dialog_counter") >= 2 then
    for entity in map:get_entities("mushroom_golem") do
      entity:set_enabled(false)
    end
  end
end

function trap_sensor:on_activated()
  if game:get_value("rohit_dialog_counter") < 2 then
    map:close_doors("gate")
    game:start_dialog("_yarrowmouth.observations.ambush_2")
  end
end



function mushroom_golem_1:on_dead()
  if map:get_entities_count("mushroom_golem") == 0 then
    game:start_dialog("_yarrowmouth.observations.mushroom_spot.1")
    game:set_value("rohit_dialog_counter", 2)
    game:set_value("puzzlewood_footprints_visible", true)
    map:open_doors("gate")
  end
end

function mushroom_golem_3:on_dead()
  if map:get_entities_count("mushroom_golem") == 0 then
    game:start_dialog("_yarrowmouth.observations.mushroom_spot.1")
    game:set_value("rohit_dialog_counter", 2)
    game:set_value("puzzlewood_footprints_visible", true)
    map:open_doors("gate")
  end
end

function mushroom_golem_4:on_dead()
  if map:get_entities_count("mushroom_golem") == 0 then
    game:start_dialog("_yarrowmouth.observations.mushroom_spot.1")
    game:set_value("rohit_dialog_counter", 2)
    game:set_value("puzzlewood_footprints_visible", true)
    map:open_doors("gate")
  end
end

function mushroom_golem_5:on_dead()
  if map:get_entities_count("mushroom_golem") == 0 then
    game:start_dialog("_yarrowmouth.observations.mushroom_spot.1")
    game:set_value("rohit_dialog_counter", 2)
    game:set_value("puzzlewood_footprints_visible", true)
    map:open_doors("gate")
  end
end