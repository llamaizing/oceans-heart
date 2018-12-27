local enemy = ...


local behavior = require("enemies/lib/toward_hero_octorok")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 12,
  damage = 6,
  normal_speed = 35,
  faster_speed = 55,
  detection_distance = 130,
  projectile_breed = "misc/fireball_red_small",
  projectile_angle = "any",
  size_x = 32, size_y = 24,
  must_be_aligned_to_shoot = false,
  shooting_frequency = 3500,  
}

behavior:create(enemy, properties)