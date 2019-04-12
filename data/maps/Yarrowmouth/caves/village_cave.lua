-- Lua script of map Yarrowmouth/caves/village_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  map:set_doors_open("boss_door")

end)

function boss_sensor:on_activated()
  map:close_doors("boss_door")
end

function boss:on_dead()
--  sol.audio.play_sound("secret")
--  map:open_doors("boss_door")
end

function exit_switch:on_activated()
  map:open_doors("exit_door")
end