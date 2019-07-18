-- Lua script of map goatshead_island/spruce_head_shrine/spruce_head_shrine.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


map:register_event("on_started", function()


end)



--Switches-------------------------------------------------
function b6_switch:on_activated()
  sol.audio.play_sound"switch"
  map:open_doors"door_b6_posts"
end



--Enemies--------------------------------------------------
for enemy in map:get_entities("c6_enemy") do
  function enemy:on_dead()
    if not map:has_entities("c6_enemy") then
      c6_chest:set_enabled(true)
      map:create_poof(c6_chest:get_position())
    end
  end
end