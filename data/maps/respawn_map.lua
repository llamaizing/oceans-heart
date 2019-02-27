-- Lua script of map blank_room.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
require("scripts/menus/respawn_screen")

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
    sol.menu.start(game, respawn_screen)
    hero:teleport(game:get_value("respawn_map"))

end

function map:on_opening_transition_finished()

end