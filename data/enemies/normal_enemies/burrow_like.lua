local enemy = ...

local behavior = require("enemies/lib/underground_random")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 5,
  damage = 6,
  normal_speed = 30,
  burrow_sound = "burrow2",
}

behavior:create(enemy, properties)

function enemy:on_dying()
  random = math.random(100)
  if random < 10 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_guts",
     treasure_variant = 1,
     }
  end
end