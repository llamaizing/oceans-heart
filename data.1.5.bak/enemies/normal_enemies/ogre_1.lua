local enemy = ...

local behavior = require("enemies/lib/melee_attacker")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 13,
  damage = 10,
  normal_speed = 25,
  faster_speed = 40,
  detection_distance = 88,
  attack_distance = 48,
  wind_up_time = 100,
}

behavior:create(enemy, properties)