-- Lua script of map oakhaven/interiors/palace.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  guard_2:set_enabled(false)
  guard_3:set_enabled(false)
  enemy_guard:set_enabled(false)
  if game:get_value("oak_palace_kitchen_fire") == true then guard_1:set_enabled(false) end
  if game:get_value("found_hazel") == true then hazel:set_enabled(false) end
end

function sensor_down:on_activated()
  if game:get_value("oak_palace_kitchen_fire") ~= true then
    game:start_dialog("_oakhaven.observations.palace_break_in.too_close_to_guard", function()
      hero:freeze()
      local m = sol.movement.create("path")
      m:set_path{6,6}
      m:start(hero, function() hero:unfreeze() end)
    end)
  end
end

function sensor_right:on_activated()
  if game:get_value("oak_palace_kitchen_fire") ~= true then
    game:start_dialog("_oakhaven.observations.palace_break_in.too_close_to_guard", function()
      hero:freeze()
      local m = sol.movement.create("path")
      m:set_path{0,0}
      m:start(hero, function() hero:unfreeze() end)
    end)
  end
end

function bomb_flower:on_exploded()
  if game:get_value("oak_palace_kitchen_fire") ~= true then
    sol.timer.start(1000, function()
      game:set_value("oak_palace_kitchen_fire", true)
      hero:freeze()
      guard_2:set_enabled(true)
      local gm = sol.movement.create("path")
      gm:set_speed(80)
      gm:set_ignore_obstacles(true)
      gm:set_path{0,0,0,0,0,0,0,0,}
      gm:start(guard_2, function()
      game:start_dialog("_oakhaven.observations.palace_break_in.guard_sees_explosion", function()
        gm:set_path{4,4,4,4,4,4,4,4,4,4,4,4,4,4,}
        gm:start(guard_2, function()
          hero:unfreeze() guard_2:set_enabled(false) guard_1:set_enabled(false)
        end)--end of run left function
      end) --end of dialog function
      end) --end of run right function
    end)
  end --end of conditional branch
end


--find hazel!
function hazel_sensor:on_activated()
  if game:get_value("found_hazel") ~= true then
    game:set_value("found_hazel", true)
    hero:freeze()
    hero:get_sprite():set_animation("walking")
    local mt = sol.movement.create("path")
    mt:set_path{0,0,0,0,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,}
    mt:set_speed(80)
    sol.timer.start(map, 1850, function() hero:get_sprite():set_direction(1) end)
    mt:start(hero, function()
    hero:get_sprite():set_animation("stopped")
    game:start_dialog("_oakhaven.npcs.hazel.palace.1", function()
      guard_3:set_enabled(true)
      local g3 = sol.movement.create("path")
      g3:set_speed(65)
      g3:set_ignore_obstacles(true)
      g3:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0}
      g3:start(guard_3, function()
        game:start_dialog("_oakhaven.npcs.hazel.palace.2", function()
          hero:unfreeze()
          local hm = sol.movement.create("path")
          hm:set_path{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
          hm:set_speed(90)
          hm:start(hazel, function()
            hazel:set_enabled(false)
            game:set_value("quest_hazel", 6) --quest log
          end)
          enemy_guard:set_enabled(true)
          guard_3:set_enabled(false)
          game:set_value("quest_log_a", "a13.5")
        end) --end of guard dialog
      end) --end of guard movement
    end) --end of first dialog function
    end) --end of Tilia movement
  end --end of if you haven't found Hazel branch
end