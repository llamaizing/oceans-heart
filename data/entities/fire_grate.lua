local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local WINDUP_TIME = 1000

-- Event called when the custom entity is initialized.
function entity:on_created()
  local frequency = entity:get_property("frequency") or 4000

  sol.timer.start(self, entity:get_property("delay") or 1, function()
    entity:shoot_fire()
    return frequency
  end)
end

function entity:shoot_fire()
  local sprite = entity:get_sprite()
  sprite:set_animation("glowing")
  if entity:get_distance(map:get_hero()) < 400 and entity:is_in_same_region(hero) then sol.audio.play_sound("steam_01") end
  sol.timer.start(entity, WINDUP_TIME, function()
    sprite:set_animation("off")
    if entity:get_distance(map:get_hero()) < 300 and entity:is_in_same_region(hero) then sol.audio.play_sound("fire_burst_2") end
    local x, y, layer = entity:get_position()
    map:create_enemy({
      x = x, y = y-8, layer = layer, direction = 0, breed = "misc/fire_blast"
    })
    map:create_enemy({
      x = x, y = y-16, layer = layer, direction = 0, breed = "misc/fire_blast"
    })
  end)
end