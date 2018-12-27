local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 90,
  damage = 16,
  normal_speed = 5,
  faster_speed = 30,
  detection_distance = 450,
  hurt_style = "boss",
  pushed_when_hurt = false,
  push_hero_on_sword = false,
  explosion_consequence = "protected",
  
}

behavior:create(enemy, properties)