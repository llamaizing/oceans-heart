-- Lua script of map new_limestone/limestone_fire.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  sol.audio.play_music("fire_burning")
  timeskip_warp:set_enabled(false)
  
--tim movement
  local tim_run = sol.movement.create("path")
  tim_run:set_path{0,0,0,0,0,0,4,4,4,4,4,4}
  tim_run:set_speed(80)
  tim_run:set_loop(true)
  tim_run:set_ignore_obstacles(true)
  tim_run:start(tim)
--juglan movement
  local juglan_movement = sol.movement.create("random")
  juglan_movement:set_speed(25)
  juglan_movement:start(juglan)

end

function explosion_sensor:on_activated()
  map:create_explosion({
  name = nil,
  layer = 0,
  x = 672,
  y = 768,
  })

end

function mallow:on_interaction()
  game:set_value("quest_log_a", "a2")
  game:start_dialog("_new_limestone_island.npcs.mallow.3", function ()
    timeskip_warp:set_enabled(true)

  end)


end