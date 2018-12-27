local enemy = ...

local behavior = require("enemies/lib/underground_random")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 5,
  damage = 6,
  normal_speed = 30,
  burrow_sound = "burrow2",
}

behavior:create(enemy, properties)