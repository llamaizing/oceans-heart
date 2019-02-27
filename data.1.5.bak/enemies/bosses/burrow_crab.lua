local enemy = ...

local behavior = require("enemies/lib/zora")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 20,
  damage = 6,
  burrow_sound = "burrow2",
  normal_speed = 60,
  hurt_style = "boss",
  pushed_when_hurt = true,
  push_hero_on_sword = true,
  time_aboveground = 800,
  burrow_deviation = 2000,
  projectile_breed = "misc/fireball_red_small",
}

behavior:create(enemy, properties)