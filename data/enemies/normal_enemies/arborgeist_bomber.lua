local enemy = ...


local behavior = require("enemies/lib/toward_hero_octorok")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 14,
  damage = 8,
  normal_speed = 15,
  faster_speed = 30,
  detection_distance = 125,
  projectile_breed = "misc/nitrodendron_bomb",
  explosion_consequence = "protected",
}

behavior:create(enemy, properties)