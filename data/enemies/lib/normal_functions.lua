--This script sets up the things you want every enemy to have. Changing the sprite on change in movement direction, etc.

local normal_functions = {}


function normal_functions:set(enemy, properties)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()

  --align the sprite with movement direction.
  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end

  --determine if enemy is near hero
  function enemy:is_near_hero()
    local layer = self:get_layer()
    local hero_layer = hero:get_layer()
    local dist_hero = self:get_distance(hero)
    local near_hero = (layer == hero_layer or enemy:has_layer_independent_collisions())
      and dist_hero <= properties.detection_distance and self:is_in_same_region(hero)
    return near_hero
  end

  --wander aimlessly
  function enemy:go_random()
    going_hero = false
    local m = properties.movement_create() --check to see what type of movement is in properties, random path is default
    if m == nil then --if not, stop the animation first
      self:get_sprite():set_animation("stopped")
      m = self:get_movement() --see if we're already moving
      if m ~= nil then
        -- Stop the previous movement.
        m:stop()
      end
    else
      m:set_speed(properties.normal_speed)
      m:set_ignore_obstacles(properties.ignore_obstacles)
      m:start(self)
      self:get_sprite():set_animation("walking")
    end
  end

  --head toward the hero
  function enemy:go_hero()

    if properties.movement_circle_hero then
      local m = sol.movement.create("circle")
      m:set_ignore_obstacles(properties.ignore_obstacles)
      m:set_center(hero)
      local angle_from_center = self:get_angle(hero)
      m:set_angle_from_center(angle_from_center + math.pi)
      m:set_radius(properties.movement_circle_hero_radius)
      m:set_radius_speed(properties.movement_circle_hero_radius_speed)
      m:start(self)
      self:get_sprite():set_animation("walking")
    else
      local m = sol.movement.create("target")
      m:set_speed(properties.faster_speed)
      m:set_ignore_obstacles(properties.ignore_obstacles)
      m:start(self)
      self:get_sprite():set_animation("walking")

    end
  end


end

return normal_functions