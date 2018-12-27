local enemy = ...


local behavior = require("enemies/lib/melee_attacker")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 13,
  damage = 10,
  normal_speed = 40,
  faster_speed = 65,
  detection_distance = 96,
  attack_distance = 60,
  wind_up_time = 150,
  attack_sound = "sword2",
}

behavior:create(enemy, properties)