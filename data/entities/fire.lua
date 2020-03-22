--[[
This is to replace the built-in fire from the engine, which is called with map:create_fire()
--]]
local fire = ...
local sprite
local game = fire:get_game()
local map = fire:get_map()


fire:set_can_traverse("crystal", true)
fire:set_can_traverse("crystal_block", true)
fire:set_can_traverse("hero", true)
fire:set_can_traverse("jumper", true)
fire:set_can_traverse("stairs", true)
fire:set_can_traverse("stream", true)
fire:set_can_traverse("switch", true)
fire:set_can_traverse("teletransporter", true)
fire:set_can_traverse_ground("deep_water", true)
fire:set_can_traverse_ground("shallow_water", true)
fire:set_can_traverse_ground("hole", true)
fire:set_can_traverse_ground("lava", true)
fire:set_can_traverse_ground("prickles", true)
fire:set_can_traverse_ground("low_wall", true)

fire:set_drawn_in_y_order(true)

function fire:on_created()
  sprite = fire:get_sprite()
  local animations = {"fire_a", "fire_b"}
  sprite:set_animation(animations[math.random(1,2)], function() fire:remove() end)
--  sprite:set_blend_mode"add"
--[[  local second_sprite = fire:create_sprite("entities/fire")
  second_sprite:set_animation(animations[math.random(1,2)])
  second_sprite:set_blend_mode"add"
--]]
end



-- Collision
fire:add_collision_test("sprite", function(fire, entity)

  --Hurt enemies
  if entity:get_type() == "enemy" then
    local enemy = entity
    local reaction = enemy:get_attack_consequence("fire")
    if reaction ~= "protected" and reaction ~= "ignored" then
      local damage = game:get_value("sword_damage")
      if enemy.weak_to_fire then damage = damage * 2 end
      enemy:react_to_fire()
      enemy:hurt(damage)
    end
  end

  --Burn bushes
  if entity:get_type() == "destructible" then
    local sprite_name = entity:get_sprite():get_animation_set()
    if string.match(sprite_name, "bush") then
      sol.audio.play_sound("bush")
      local x,y,z = entity:get_position()
      entity:remove()
      map:create_fire{x=x,y=y,layer=z}
      sol.audio.play_sound"fire_burst_3"
      sol.timer.start(map, 200, function()
        local dx = {8,0,-8,0}
        local dy = {0,-8,0,8}
        for i=1, 4 do
          map:create_fire{
            x=x + dx[i], y=y + dy[i], layer=z
          }
        end
      end)
    end
  end
end)