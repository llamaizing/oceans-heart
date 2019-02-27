-- Lua script of map ballast_harbor/council_building.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  self:get_camera():letterbox()
  charging_pirate:set_enabled(false)
  return_sensor:set_enabled(false)
  if game:get_value("ballast_charging_pirate_defeated") == true then
    charging_pirate_sensor:set_enabled(false)
    fake_charger:set_enabled(false)
  end

  if game:get_value("ballast_harbor_blackbeard_scene") == true then
    brutus:set_enabled(false)
    blackbeard:set_enabled(false)
  end

end)

function front_door_switch:on_activated()
  map:open_doors("front_door")
end

function bookshelf_switch:on_activated()
  sol.audio.play_sound("secret")
  local m = sol.movement.create("path")
  m:set_path{0,0,0,0,}
  m:set_ignore_obstacles(true)
  m:start(bookshelf_1)
  local m2 = sol.movement.create("path")
  m2:set_path{0,0,0,0,}
  m2:set_ignore_obstacles(true)
  m2:start(bookshelf_2)
end

function return_sensor:on_activated()
  local m = sol.movement.create("path")
  m:set_path{4,4,4,4}
  m:set_ignore_obstacles(true)
  m:start(bookshelf_1)
  local m2 = sol.movement.create("path")
  m2:set_path{4,4,4,4}
  m2:set_ignore_obstacles(true)
  m2:start(bookshelf_2)
end

function return_sensor_2:on_activated()
  return_sensor:set_enabled(true)
end

function charging_pirate_sensor:on_activated()
  game:start_dialog("_ballast_harbor.npcs.charging_pirate.1", function()
    fake_charger:set_enabled(false)
    charging_pirate:set_enabled(true)
    charging_pirate_sensor:set_enabled(false)
  end)
end

function charging_pirate:on_dead()
  map:open_doors("boss_exit_door")
  game:set_value("ballast_charging_pirate_defeated", true)
end


--cutscene
function blackbeard_sensor:on_activated()
  if game:get_value("ballast_harbor_blackbeard_scene") ~= true then
    game:start_dialog("_ballast_harbor.npcs.council_cutscene.1", function()
    local p1 = sol.movement.create("path")
    p1:set_path{4,4,4,4,4,4,4,4,4,4,4,4,}
    p1:set_ignore_obstacles(true)
    p1:start(brutus)
    local p2 = sol.movement.create("path")
    p2:set_path{4,4,4,4,4,4,4,4,4,4,4,4,}
    p2:set_ignore_obstacles(true)
    p2:start(blackbeard)
    game:set_value("ballast_harbor_blackbeard_scene", true)

    function p2:on_finished()
      brutus:set_enabled(false)
      blackbeard:set_enabled(false)
    end

    end)
  end
end