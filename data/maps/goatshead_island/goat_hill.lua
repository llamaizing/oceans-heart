-- Lua script of map goatshead_island/goat_hill.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("gtshd_music_headed_toward_town") == false then sol.audio.play_music("goatshead_harbor") end

  local random_walk = sol.movement.create("random_path")
  random_walk:set_speed(15)
  random_walk:set_ignore_obstacles(false)
  random_walk:start(goat_1)

  local random_walk2 = sol.movement.create("random_path")
  random_walk2:set_speed(10)
  random_walk2:set_ignore_obstacles(false)
  random_walk2:start(goat_2)

  local random_walk3 = sol.movement.create("random_path")
  random_walk3:set_speed(12)
  random_walk3:set_ignore_obstacles(false)
  random_walk3:start(goat_3)

  local random_walk4 = sol.movement.create("random_path")
  random_walk4:set_speed(19)
  random_walk4:set_ignore_obstacles(false)
  random_walk4:start(goat_4)

  local random_walk5 = sol.movement.create("random_path")
  random_walk5:set_speed(4)
  random_walk5:set_ignore_obstacles(false)
  random_walk5:start(abberforth)

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function guard_3:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.7")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end

function guard_4:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.6")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end