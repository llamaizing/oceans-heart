local entity = ...
local game = entity:get_game()
local map = entity:get_map()


function entity:on_created()
  entity:set_traversable_by(false)
  entity:set_traversable_by("hero", true)
  entity:set_impassable_by_hero()
  entity:set_drawn_in_y_order(true)
  entity:set_follow_streams(true)
  entity:set_traversable_by("enemy", true)
  entity:set_weight(1)
  if entity:get_property("weight") then
    entity:set_weight(entity:get_property("weight"))
  end
end

--Bash into enemies
local enemies_touched = {}
entity:add_collision_test("sprite", function(entity, other)
  if other:get_type() == "enemy" then
    local enemy = other
    if not enemies_touched[enemy] and enemy:hit_by_toss_ball() then
      enemy:hit_by_toss_ball()
    end
    enemies_touched[enemy] = enemy
    sol.timer.start(map, 2000, function() enemies_touched[enemy] = false end)
  end
end)




function entity:on_lifting(carrier, carried_object)
  carried_object:set_damage_on_enemies(game:get_value("sword_damage") + 4)
  if entity:get_property("damage") then
    entity:set_weight(entity:get_property("damage"))
  end
  carried_object:set_destruction_sound("running_obstacle")

  --landing, and therefore needing to create a new toss_ball
  function carried_object:on_breaking()
    map:get_camera():shake({count = 3, amplitude = 5, speed = 80})
    local x, y, layer = carried_object:get_position()
    local width, height = carried_object:get_size()
    local sprite = carried_object:get_sprite()
    local direction = sprite:get_direction()

    if carried_object:get_ground_below() == "wall" then y = y + 16 end
    carried_object:get_map():create_custom_entity({
      width = width, height = height, x = x, y = y, layer = layer,
      direction = direction, model = "toss_ball", sprite = sprite:get_animation_set()
    })
  end

end


function entity:set_impassable_by_hero()
  if not map:get_hero():overlaps(entity) then
    entity:set_traversable_by("hero", false)
    return
  end
  sol.timer.start(10, function() -- Retry later.
    entity:set_impassable_by_hero()
  end)
end