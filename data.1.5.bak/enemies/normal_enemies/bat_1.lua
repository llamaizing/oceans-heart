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