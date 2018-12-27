-- Lua script of map goatshead_island/ball_trail.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

for sensor in map:get_entities("ssg_sensor") do
function sensor:on_activated() hero:save_solid_ground() end
end

for sensor in map:get_entities("rsg_sensor") do
function sensor:on_activated() hero:reset_solid_ground() end
end