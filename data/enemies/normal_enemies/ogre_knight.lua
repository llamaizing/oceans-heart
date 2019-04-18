local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/ogre")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 18,
  damage = 17,
  normal_speed = 15,
  faster_speed = 65,
  detection_distance = 120,
  attack_distance = 55,
  wind_up_time = 450,
  attack_sound = "sword2",
  must_be_aligned_to_attack = false,
  push_hero_on_sword = true,
  attack_sprites = {"enemies/misc/sword_slash", "enemies/misc/air_wave"},
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

function enemy:on_dying()
  random = math.random(100)
  if random < 25 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_eye",
     treasure_variant = 1,
     }
  end
end