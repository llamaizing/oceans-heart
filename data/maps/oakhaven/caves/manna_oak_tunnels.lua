-- Lua script of map oakhaven/caves/manna_oak_tunnels.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  if game:get_value("spoken_with_hazel_in_manna_oak_tunnels") then
    gonna_die_blob:set_enabled(false)
  end
  if game:get_value("quest_manna_oaks") >= 8 then
    hazel:set_enabled(false)
    for blob in map:get_entities("pollutant") do
      blob:remove()
    end
  end
end

--Hazel cutscene
function see_hazel_sensor:on_activated()
  if not game:get_value("spoken_with_hazel_in_manna_oak_tunnels") then
    hero:freeze()
    gonna_die_blob:remove_life(100)
    sol.timer.start(map, 800, function()
      map:get_hero():walk("666666666644")
      sol.timer.start(map, 1000, function()
        hero:unfreeze()
        game:start_dialog("_oakhaven.npcs.hazel.tunnels.1")
        game:set_value("spoken_with_hazel_in_manna_oak_tunnels", true)
      end)
    end)
  end
end


--Bosses
for boss in map:get_entities("boss_pollutant") do
  function boss:on_dead()
    game:set_value("manna_oaks_investigated", game:get_value("manna_oaks_investigated") +1)
    if game:get_value("manna_oaks_investigated") >= 3 then
      if hazel:is_enabled() then hazel:set_enabled(false) end
      map:get_camera():shake({count = 12, amplitude = 7, speed = 80})
      --destroy all the monsters and blockers
      for blob in map:get_entities("pollutant") do
        blob:remove_life(100)
      end
      --update quest log
      game:set_value("quest_manna_oaks", 8)
    end
  end
end

--enter shrine
function entered_shrine_sensor:on_activated()
  game:set_value("quest_manna_oaks", 9)
end