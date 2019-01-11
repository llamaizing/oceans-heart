local enemy = ...

local behavior = require("enemies/lib/zora")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 10,
  damage = 8,
  burrow_sound = "splash",
  obstacle_behavior = "swimming",
  projectile_breed = "misc/energy_ball_split",
  projectile_damage = 2,
  time_aboveground = 2000
  
}

behavior:create(enemy, properties)