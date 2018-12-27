local enemy = ...


local behavior = require("enemies/lib/melee_attacker")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 18,
  damage = 16,
  normal_speed = 25,
  faster_speed = 40,
  detection_distance = 104,
  attack_distance = 48,
  wind_up_time = 100,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = true,
  
}

behavior:create(enemy, properties)