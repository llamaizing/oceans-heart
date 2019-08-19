-- Lua script of map heron_door_test_room.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function door_item_sensor:on_activated()
  if not game:has_item("heron_door_snapmast") then
    game:get_item("heron_door_snapmast"):set_variant(1)
    game:set_value("found_heron_door_snapmast", 1)
print("you got an item snapmast")
  end
end

function door_item_sensor_2:on_activated()
  if not game:has_item("heron_door_marble_summit") then
    game:get_item("heron_door_marble_summit"):set_variant(1)
    game:set_value("found_heron_door_marble_summit", 1)
print("you got an item marblecliff")
  end
end

function door_item_sensor_3:on_activated()
  if not game:has_item("heron_door_tern_marsh") then
    game:get_item("heron_door_tern_marsh"):set_variant(1)
    game:set_value("found_heron_door_tern_marsh", 1)
print("you got an item tern marsh")
  end
end



function monk:on_interaction()
  game:get_item("thunder_charm"):set_variant(1)
  game:set_value("possession_thunder_charm", 1)
print("I gave you the charm")
--  game:set_value("quest_heron_doors", 0)
  game:set_value("heron_doors", 0)
  game.objectives:set_alternate("heron_doors_alt", "quest.heron_doors")
end