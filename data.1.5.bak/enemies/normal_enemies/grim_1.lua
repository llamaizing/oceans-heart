local enemy = ...

local behavior = require("enemies/lib/underground_toward_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 40,
  damage = 30,
  normal_speed = 20,
  faster_speed = 91,
  detection_distance = 70,
  time_aboveground = 2000,
  time_underground = 3000,
  burrow_deviation = 4000,
  pushed_when_hurt = false,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end,
  projectile_breed = "misc/zora_fire",
}

behavior:create(enemy, properties)