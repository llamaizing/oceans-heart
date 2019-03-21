-- Lua script of map debug_room.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  hero = game:get_hero()
  hero:set_walking_speed(96)
  HIDETHESE:set_visible(false)

end)


function camera_shaker:on_interaction()
  map:get_camera():shake({count = 6, amplitude = 4, speed = 80})
end

function current_switch:on_activated()
  for e in map:get_entities("current_a") do
    local new_direction = e:get_direction() + 4
    if new_direction > 7 then new_direction = new_direction - 8 end
    e:set_direction(new_direction)
  end
end
function current_switch:on_inactivated()
  for e in map:get_entities("current_a") do
    local new_direction = e:get_direction() + 4
    if new_direction > 7 then new_direction = new_direction - 8 end
    e:set_direction(new_direction)
  end
end