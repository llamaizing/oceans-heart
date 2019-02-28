local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 35,
  damage = 20,
  normal_speed = 20,
  faster_speed = 30,
  detection_distance = 140,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  --Attacks--
  has_radial_attack = true,
  radial_attack_projectile_breed = "misc/energy_ball_small",
  radial_attack_cooldown = 3500,
  radial_attack_distance = 70,
  radial_attack_num_projectiles = 5,
  radial_attack_stop_while_charging = true,

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:register_event("on_created", function()
  enemy:set_obstacle_behavior("flying")
end)