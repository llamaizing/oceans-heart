local enemy = ...

local behavior = require("enemies/lib/zora")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 28,
  damage = 6,
  burrow_sound = "burrow2",
  normal_speed = 60,
  hurt_style = "boss",
  pushed_when_hurt = true,
  push_hero_on_sword = true,
  time_aboveground = 1600,
  burrow_deviation = 2000,
  projectile_breed = "misc/energy_ball_black_2",
}

behavior:create(enemy, properties)