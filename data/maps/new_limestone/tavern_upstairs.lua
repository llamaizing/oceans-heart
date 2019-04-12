-- Lua script of map new_limestone/tavern_upstairs.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = game:get_hero()
local sprite = hero:get_sprite()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  hero:set_walking_speed(98) --can't do this in initial game because

  if not game:get_value("waking_up_beginning_of_game_cutscene") then
    hero:freeze()
    sprite:set_animation("asleep")
  end
end

function map:on_opening_transition_finished()
  if not game:get_value("waking_up_beginning_of_game_cutscene") then
    hero:freeze()
    sprite:set_animation("asleep")
    sol.timer.start(map, 500, function()
      sprite:set_animation("waking_up", function()
        sprite:set_animation("stopped")
        hero:start_jumping(0, 24, true)
        sol.timer.start(map, 500, function() hero:unfreeze() end)
      end)
    end)

    game:set_value("waking_up_beginning_of_game_cutscene", true)
  end
end
