local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")

local properties = {
  sprite = "enemies/bosses/jazari",
  hurt_style = "boss",
  life = 35,
  damage = 10,
  normal_speed = 15,
  faster_speed = 60,
  wind_up_time = 500,
  has_melee_attack = true,
  melee_distance = 70,
  melee_attack_cooldown = 3500,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/sword_slash"},
  has_summon_attack = true,
  summon_attack_distance = 200,
  summon_attack_cooldown = 9000,
  summoning_sound = "cane",
  summon_breed = "misc/steam_attack",
  summon_group_size = 4,
  summon_group_delay = 1000,
  protected_while_summoning = true,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

--has_melee_attack, melee_distance, melee_attack_cooldown, attack_sprites{} (a table of sprites)
    --optional, melee_attack_wind_up_time (this is an optional property for each attack, assume it's true for all)--has_summon_attack, summon_attack_distance, summon_attack_cooldown, summon_breed, summon_group_size, summon_group_delay
    --summon group size refers to, for instance, if the enemy summons 3 bolts of lightning at a time.
    --summon group delay refers to time between each of those 3 bolts of lightning. After that, cooldown will start