local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local WINDUP_TIME = 1000
local turned_off = false

-- Event called when the custom entity is initialized.
function entity:on_created()
  local frequency = entity:get_property("frequency") or 4000

  sol.timer.start(self, entity:get_property("delay") or 1, function()
    if not turned_off then entity:shoot_fire() end
    return frequency
  end)
end

function entity:shoot_fire()
  local sprite = entity:get_sprite()
  sprite:set_animation("glowing")
  if entity:get_distance(hero) < 400 and entity:is_in_same_region(hero) then sol.audio.play_sound("steam_01") end
  sol.timer.start(entity, WINDUP_TIME, function()
    sprite:set_animation("off")
    if entity:get_distance(map:get_hero()) < 300 and entity:is_in_same_region(hero) then sol.audio.play_sound("fire_burst_2") end
    local x, y, layer = entity:get_position()
    local fire_blast = map:create_enemy({
      x = x, y = y-4, layer = layer, direction = 0, breed = "misc/fire_blast"
    })
    local extra_fire_sprite = fire_blast:create_sprite("entities/fire")
    extra_fire_sprite:set_animation("fire_a")
  end)
end

function entity:set_turned_off(state)
  turned_off = state
end