local enemy = ...

local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 4,
  damage = 1,
  normal_speed = 15,
  faster_speed = 50,
  distance = 65,
}

behavior:create(enemy, properties)