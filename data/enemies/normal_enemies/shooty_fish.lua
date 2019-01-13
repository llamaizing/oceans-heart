local enemy = ...

local behavior = require("enemies/lib/zora")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 1,
  damage = 8,
  burrow_sound = "splash",
  obstacle_behavior = "swimming",
  projectile_breed = "zora_fire",
  
}

behavior:create(enemy, properties)