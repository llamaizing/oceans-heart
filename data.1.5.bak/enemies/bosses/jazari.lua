local enemy = ...


local behavior = require("enemies/lib/melee_summoner")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "boss",
  life = 35,
  damage = 10,
  normal_speed = 15,
  faster_speed = 60,
  detection_distance = 200,
  projectile_breed = "misc/steam_attack",
  melee_distance = 70,
  ranged_distance = 170,
  wind_up_time = 300,
  melee_cooldown = 3500,
  ranged_cooldown = 9000,
  melee_sound = "sword2",
  summon_sound = ("cane"),
  max_summons = 4,
  summon_frequence = 1000,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  protected_while_summoning = true,
}

behavior:create(enemy, properties)