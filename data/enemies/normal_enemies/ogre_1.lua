local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/ogre")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 13,
  damage = 10,
  normal_speed = 25,
  faster_speed = 50,
  detection_distance = 88,
  attack_distance = 64,
  wind_up_time = 150,
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

