local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local sprite
local SPEED = 120
local following_hero
local in_water

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
  local dist = entity:get_distance(hero)
  if dist <= 16 and following_hero then
    entity:stop_walking()
  elseif dist >= 32 and not following_hero then
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
  if entity:get_distance(hero) > 64 then m:set_speed(SPEED * 2) end
  m:start(entity)
--  m:set_ignore_obstacles(true)
  sprite:set_animation("walking")

  function m:on_changed()
    sprite:set_direction(m:get_direction4())
    m:set_ignore_obstacles(false)
    local ground = entity:get_ground_below()
    if not in_water and ground == "shallow_water" then
      in_water = true 
      entity:create_sprite("hero/ground2", "water_sprite")
    elseif in_water and ground ~= "shallow_water" then
      in_water = false
      entity:remove_sprite(entity:get_sprite("water_sprite"))
    end
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

