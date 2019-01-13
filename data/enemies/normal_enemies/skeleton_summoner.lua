local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/ranged_attacker")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 5,
  damage = 4,
  normal_speed = 25,
  faster_speed = 27,
  detection_distance = 125,
  projectile_breed = "misc/energy_ball_bounce",
  projectile_angle = "any",
  projectile_damage = 2,
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)