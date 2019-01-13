local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 40,
  damage = 30,
  normal_speed = 20,
  faster_speed = 85,
  detection_distance = 75,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 70,
  melee_attack_cooldown = 3000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},

--  has_teleport = true,
  teleport_wind_up = 400,
  teleport_distance = 60,
  teleport_cooldown = 10000,
  invincible_while_charging_teleport = false,
  teleport_length = 120,
  time_phased_out = 2500,

  has_orbit_attack = true,
  orbit_attack_distance = 190,
  orbit_attack_cooldown = 7000,
  orbit_attack_sound = "gravel",
  orbit_attack_launch_sound = "shoot",
  orbit_attack_num_projectiles = 5,
  orbit_attack_charge_time = 1000,
  orbit_attack_shoot_delay = 500,
  orbit_attack_projectile_delay = 200,
--  orbit_attack_projectile_breed = "misc/energy_ball_small",
  orbit_attack_projectile_breed = "normal_enemies/bat_1",
  orbit_attack_radius = 16,

--for circleing hero movement:
  movement_circle_hero = true,
  movement_circle_hero_radius = 64,
    movement_circle_hero_radius_speed = 25,

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)