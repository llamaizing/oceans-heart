local enemy = ...


local behavior = require("enemies/lib/toward_hero_octorok")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 7,
  damage = 12,
  normal_speed = 35,
  faster_speed = 35,
  detection_distance = 125,
  projectile_breed = "misc/zora_fire",
  projectile_angle = "any",
}

behavior:create(enemy, properties)