local enemy = ...


local behavior = require("enemies/lib/sentry")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 18,
  damage = 17,
  normal_speed = 15,
  faster_speed = 65,
  detection_distance_facing = 120,
  detection_distance_away = 75,
  attack_distance = 55,
  wind_up_time = 450,
  attack_sound = "sword2",
  must_be_aligned_to_attack = false,
  push_hero_on_sword = true,
}

behavior:create(enemy, properties)