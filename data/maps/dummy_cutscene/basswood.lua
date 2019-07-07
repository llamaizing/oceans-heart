-- Lua script of map dummy_cutscene/basswood.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local black = sol.surface.create()
black:fill_color{0,0,0}
black:set_opacity(0)

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end


function map:on_opening_transition_finished()
  hero:freeze()
  local m = sol.movement.create"path"
  m:set_path{2,2}
  m:start(mallow, function()
    sol.timer.start(map, 200, function()
      game:start_dialog("_endgame.basswood_1", function()
        mallow:get_sprite():set_animation"hug_open"
        m:set_path{6,6,6,6,6}
        m:set_speed(80)
        m:start(linden,function() mallow:get_sprite():set_animation"hug_closed" end)
        sol.timer.start(map, 500, function()
          black:fade_in(150, function()
            sol.menu.start(sol.main, require("scripts/menus/credits"))
          end)
        end)
      end)
    end)
  end)
end

function map:on_draw(s)
  black:draw(s)
end
