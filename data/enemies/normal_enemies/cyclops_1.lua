local enemy = ...


local behavior = require("enemies/lib/hinox")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 12,
  damage = 11,
  normal_speed = 25,
  faster_speed = 35,
  detection_distance = 96,
}

behavior:create(enemy, properties)

function enemy:on_dead()
  random = math.random(100)
  if random < 20 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "bomb",
     treasure_variant = 2,
     }
  end
end