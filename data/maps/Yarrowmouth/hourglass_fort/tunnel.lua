-- Lua script of map Yarrowmouth/hourglass_fort/tunnel.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  self:get_camera():letterbox()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end