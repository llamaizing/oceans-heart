-- Lua script of map goatshead_island/spruce_head_shrine/spruce_head_shrine.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


map:register_event("on_started", function()

  map:set_doors_open("d4_door")

end)



--Switches-------------------------------------------------
function b6_switch:on_activated()
  sol.audio.play_sound"switch"
  map:open_doors"door_b6_posts"
end



--Sensors--------------------------------------------------
function miniboss_sensor:on_activated()
  if not game:get_value("ssh_miniboss_defeated") then
    map:close_doors("d4_door")
    for e in map:get_entities("miniboss_wall") do
      e:set_enabled(false)
    end
    miniboss_sensor:set_enabled(false)
  end
end




--Enemies--------------------------------------------------
for enemy in map:get_entities("c6_enemy") do
  function enemy:on_dead()
    if not map:has_entities("c6_enemy") then
      c6_chest:set_enabled(true)
      map:create_poof(c6_chest:get_position())
      sol.audio.play_sound"secret"
    end
  end
end

  --Miniboss--
function miniboss:on_dead()
  map:open_doors("d4_door")
  map:open_doors("c4_door")
  d4_chest:set_enabled(true)
  map:create_poof(d4_chest:get_position())
  sol.audio.play_sound"secret"
end