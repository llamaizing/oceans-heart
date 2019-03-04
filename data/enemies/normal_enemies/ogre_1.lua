local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/ogre")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 6,
  damage = 2,
  normal_speed = 25,
  faster_speed = 40,
  detection_distance = 96,
  attack_distance = 90,
  wind_up_time = 500,
  attack_frequency = 1900,
  attack_sprites = {"enemies/misc/air_wave"},
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

