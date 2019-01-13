local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  size_x = 24,
  life = 1,
  damage = 1,
--  ignore_obstacles = true,
  obstacle_behavior = "flying",
  normal_speed = 75,
  faster_speed = 75,
  detection_distance = 2,
}

behavior:create(enemy, properties)

enemy:set_layer_independent_collisions(true)

function enemy:go(angle)
  local m = sol.movement.create("straight")
  m:set_speed(100)
  m:set_angle(angle)
  m:set_max_distance(120)
  m:start(enemy)
  function m:on_finished() enemy:restart() end
  function m:on_obstacle_reached() enemy:restart() end
end