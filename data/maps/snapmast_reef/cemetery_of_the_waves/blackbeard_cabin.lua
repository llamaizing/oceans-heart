-- Lua script of map snapmast_reef/cemetery_of_the_waves/blackbeard_cabin.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
loca hero = map:get_hero()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain_inside")
  map:set_doors_open("boss_doors")
  if not game:get_value("assassinbeard_killed") then assassinbeard:set_enabled(true) end
end)



function boss_sensor:on_activated()
  boss_wall:set_enabled(false)
  map:close_doors("boss_doors")
  --insert dialog here
end

function assassinbeard:on_dead()
  game:set_value("assassinbeard_killed", true)
  map:open_doors("boss_doors")
  map:create_pickable({
    layer = 0, x = 208, y = 592, treasure_name = "health_upgrade",
  })
end

function first_mate:on_interaction()
  if game:get_value("quest_snapmast") ~= 3 then
    game:start_dialog("_snapmast.cemetery_of_the_waves.first_mate.1", function()
      hero:start_treasure("oceansheart_chart", function()
        game:set_value("quest_snapmast", 3)
        game:set_value("quest_isle_of_storms", 0)
      end)
    end)
  else
    game:start_dialog("_snapmast.cemetery_of_the_waves.first_mate.2")
  end
end