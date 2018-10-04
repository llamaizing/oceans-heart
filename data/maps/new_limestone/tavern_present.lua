-- Lua script of map new_limestone/tavern_present.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("briarwood_distillery_quest_complete") == true then
    for entity in map:get_entities("briarwood_gin") do
      entity:set_enabled(true)
    end
  end

end


-- Mandatory Linden Talk
function talk_to_linden_sensor:on_activated()
local linden_check = game:get_value("linden_dialog_check")
if linden_check ~= true then
  local see_linden_movement = sol.movement.create("target")
  hero:freeze()
  see_linden_movement:set_target(112,96)
  see_linden_movement:set_ignore_obstacles(true)
  hero:set_direction(0)
  linden_movement = sol.movement.create("path")
  linden_movement:set_path{4}
  linden_movement:start(linden)
  hero:set_animation("walking")
  see_linden_movement:start(hero, function()
    game:start_dialog("_new_limestone_island.npcs.linden.4", function()
      if game:has_item("sword") == true then
        game:start_dialog("_new_limestone_island.npcs.linden.7")
      else
        game:start_dialog("_new_limestone_island.npcs.linden.6")
      end
      hero:unfreeze()
      game:set_value("linden_dialog_check", true)
    end)

  end)
end
end

function linden:on_interaction()
  game:start_dialog("_new_limestone_island.npcs.linden.5")
end