-- Lua script of map new_limestone/stash.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  map:set_doors_open("boss_door")
  if game:get_value("quest_whisky_for_juglan") and game:get_value("quest_whisky_for_juglan") < 1 then
    whisky:set_enabled(false)
  end
  if game:get_value("limestone_island_sea_hag_killed") then
    sea_hag:set_enabled(false)
    boss_sensor:set_enabled(false)
  end
end)



----Falling Rock---------
function map:create_falling_rock(x, y, l)
  map:create_enemy{
    direction = 0, layer = l, x = x + math.random(-16, 16), y = y + math.random(-16, 16),
    breed = "misc/falling_rock"
  }
end


---------


function whisky:on_interaction()
    game:set_starting_location("new_limestone/stash", "found_whisky")

    game:set_value("quest_whisky_for_juglan_phase", 1) --quest log
    game:set_value("possession_whisky_for_juglan", 1) --add item to inventory

    whisky:set_enabled(false)
    hero:freeze()
    local i = 1
    local x1, y1, l1 = collapsing_bridge_2:get_position()
    local x2, y2, l2 = collapsing_bridge_5:get_position()
    map:create_falling_rock(x1, y1, l1)
    map:create_falling_rock(x2, y2, l2)
    for bridge in map:get_entities("collapsing_bridge") do
      sol.timer.start(map, i * 100 + 1000, function()
        sol.audio.play_sound("wood_breaking_and_falling_into_water")
        bridge:set_enabled(false)
      end)
      i = i + 1
    end
    sol.timer.start(map, 2000, function()
        game:start_dialog("_new_limestone_island.observations.trapped_in_stash")
        hero:unfreeze()
    end)
end



----switches-----
function a1_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("a1_door")
end

function b2_switch:on_activated()
  map:open_doors("b2_door")
end

function b2_switch:on_inactivated()
  map:close_doors("b2_door")
end


--sensor----
function boss_sensor:on_activated()
  map:close_doors("boss_door")
  game:start_dialog("_new_limestone_island.observations.sea_hag")
  boss_sensor:set_enabled(false)

  local i = 1
  sol.timer.start(map, 1000, function()
    if map:has_entity("sea_hag") then
      local x, y, l = hero:get_position()
      map:create_falling_rock(x, y, l)
      if i < math.random(3, 6) then
        i = i + 1
        return math.random(1000, 2500)
      else
        i = 1
        return math.random(4000, 5000)
      end
    end
  end)

end

function sea_hag:on_dead()
  map:open_doors("boss_door")
  game:set_value("limestone_island_sea_hag_killed", true)
end