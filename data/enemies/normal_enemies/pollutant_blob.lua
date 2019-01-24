local enemy = ...
local map = enemy:get_map()

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 20,
  damage = 10,
  normal_speed = 20,
  faster_speed = 55,
  detection_distance = 100,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  --Attacks--
  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 70,
  melee_attack_cooldown = 3000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},

--  has_ranged_attack = true,
  ranged_attack_distance = 170,
  ranged_attack_cooldown = 5000,
  ranged_attack_sound = "heart",
  projectile_breed = "misc/energy_ball_bounce",
--optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces, if the projectile breed will accept them!
  projectile_angle = "any",


  has_dash_attack = true,
  dash_attack_distance = 160,
  dash_attack_cooldown = 6000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 120,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,
  dash_attack_sound = "running",
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:register_event("on_created", function()
  sol.timer.start(map, math.random(100,225), function()
      local x, y, layer = enemy:get_position()
      local particle = map:create_custom_entity{
      name = "enemy_particle_effect",
      direction = enemy:get_sprite():get_direction(),
      layer = layer,
      x = math.random(x-8, x+8),
      y = math.random(y-8, y+8),
      width = 8,
      height = 8,
      sprite = "entities/pollution_ash",
      model = "dash_moth"
      }
      particle:set_drawn_in_y_order(true)
      if enemy:exists() and enemy:is_enabled() then return true end
  end)
end)