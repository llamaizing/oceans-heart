local enemy = ...


local behavior = require("enemies/lib/sentry")
enemy.immobilize_immunity = true

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 20,
  damage = 17,
  normal_speed = 15,
  faster_speed = 65,
  detection_distance_facing = 110,
  detection_distance_away = 74,
  attack_distance = 55,
  wind_up_time = 300,
  attack_sound = "sword2",
  must_be_aligned_to_attack = false,
  push_hero_on_sword = true,
}

behavior:create(enemy, properties)