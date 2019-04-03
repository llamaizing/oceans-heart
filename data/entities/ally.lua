local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite
local SPEED = 120
local following_hero

function entity:on_created()
  sprite = entity:get_sprite()
  entity:set_drawn_in_y_order(true)
  entity:set_can_traverse_ground("shallow_water", true)

  sol.timer.start(map, 400, function()
    entity:check_hero()
    return true
  end)
end

function entity:check_hero()
  local dist = entity:get_distance(map:get_hero())
  if dist <= 24 and following_hero then
    entity:stop_walking()
  elseif dist >= 50 and not following_hero then
    entity:follow_hero()
  end
--  if dist > 400 then
--    entity:set_can_traverse_ground("wall", true)
--    entity:set_can_traverse_ground("deep_water", true)
--  end
end

function entity:follow_hero()
  following_hero = true
  local m = sol.movement.create("path_finding")
  m:set_speed(SPEED)
  m:start(entity)
--  m:set_ignore_obstacles(true)
  sprite:set_animation("walking")

  function m:on_changed()
    sprite:set_direction(m:get_direction4())
    m:set_ignore_obstacles(false)
  end

  function m:on_obstacle_reached()
    sol.timer.start(map, 1000, function() m:set_ignore_obstacles(true) end)
  end
end

function entity:stop_walking()
  following_hero = false
  local direction = sprite:get_direction()
  entity:stop_movement()
  sprite:set_direction(direction)
  sprite:set_animation("stopped")
end

