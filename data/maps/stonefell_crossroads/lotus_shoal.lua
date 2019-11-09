-- Lua script of map stonefell_crossroads/lotus_shoal.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("boomerang_fort_boss_killed") then
    boomerang_boss:set_enabled(false)
    map:set_doors_open("fort_boss_door")
  end
--  bait_monster:set_enabled(false)

end)


----Fort------
function fort_switch_1:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), fort_door_1, function()
    map:open_doors("fort_door_1")
  end)
end

function fort_switch_2:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), fort_door_2, function()
    map:open_doors("fort_door_2")
  end)
end

function boomerang_boss:on_dead()
  game:set_value("boomerang_fort_boss_killed", true)
  map:open_doors("fort_boss_door")
end
