local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")

local properties = {
  sprite = "enemies/normal_enemies/pirate_bruiser",
  hurt_style = "normal",
  life = 10,
  damage = 4,
  normal_speed = 10,
  faster_speed = 35,
  detection_distance = 150,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,
  has_shield = true,
  shield_sprite = "enemies/normal_enemies/pirate_bruiser_shield", --this is an example

  --Attacks--
--  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 70,
  melee_attack_cooldown = 5000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},


  has_dash_attack = true,
  dash_attack_distance = 150,
  dash_attack_cooldown = 6000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 80,
  dash_attack_wind_up = 600,  
  dash_attack_sound = "running",


}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

function enemy:hit_by_toss_ball()
--    enemy:remove_sprite(enemy.shield_sprite)
end