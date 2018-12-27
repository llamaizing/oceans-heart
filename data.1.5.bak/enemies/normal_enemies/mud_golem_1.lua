local enemy = ...


local behavior = require("enemies/lib/melee_attacker")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 16,
  damage = 10,
  normal_speed = 20,
  faster_speed = 35,
  detection_distance = 96,
  attack_distance = 60,
  wind_up_time = 250,
  attack_sound = "gravel_2",
}

behavior:create(enemy, properties)


function enemy:on_dead()
  random = math.random(100)
  if random < 35 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "geode",
     treasure_variant = 2,
     }
  end
end