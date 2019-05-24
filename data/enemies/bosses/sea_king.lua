local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
--local movement
local angle = 0

local attacking = false
local can_throw_sword = true
local can_summon_hands = true
local can_surround_attack = true
local can_tide_attack = true
local can_pattern_attack = true
local can_projectile_a = true
local can_quake = true

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  local smoke_sprite = enemy:create_sprite("enemies/ghost_smoke_large")
  enemy:bring_sprite_to_back(smoke_sprite)

  enemy:set_life(60)
  enemy:set_damage(25)
  enemy:set_pushed_back_when_hurt(false)
end

function enemy:go_back_and_forth()
  local movement = sol.movement.create("straight")
  movement:set_speed(70)
  movement:set_angle(angle)
  movement:start(enemy)
  function movement:on_obstacle_reached()
    angle = angle + math.pi
    enemy:go_back_and_forth()
  end
end

function enemy:on_restarted()
  enemy:go_back_and_forth()
  sol.timer.start(enemy, 100, function()
    enemy:check_to_attack()
    return true
  end)
end


function enemy:finish_attacking()
  attacking = false
end


--Select an Attack:
function enemy:check_to_attack()
  if not attacking then
    if can_throw_sword and enemy:get_distance(hero) < 136 then
      attacking = true
      can_throw_sword = false
      enemy:throw_sword()
      sol.timer.start(map, 10000, function() can_throw_sword = true end)

    elseif can_surround_attack then
      attacking = true
      can_surround_attack = false
      enemy:surround_attack()
      sol.timer.start(map, 10000, function() can_surround_attack = true end)

    elseif can_tide_attack then
      attacking = true
      can_tide_attack = false
      enemy:tide_attack()
      sol.timer.start(map, 10000, function() can_tide_attack = true end)

    elseif can_pattern_attack then
      attacking = true
      can_pattern_attack = false
      enemy:pattern_attack()
      sol.timer.start(map, 10000, function() can_pattern_attack = true end)

    elseif can_projectile_a then
      attacking = true
      can_projectile_a = false
      enemy:projectile_a()
      sol.timer.start(map, 10000, function() can_projectile_a = true end)
    end
  end  
end


--Throw Sword
function enemy:throw_sword()
  local SPEED = 200
  local DISTANCE = 180
  sprite:set_animation("wind_up_sword")
  sol.timer.start(enemy, 500, function()
    sprite:set_animation("attack", function()
      sprite:set_animation("walking")
    end)
        local x, y, layer = enemy:get_position()
    local boomerang = enemy:create_enemy({
      name = "enemy_thrown_boomerang",
      x = 0, y = 0, layer = layer, direction = 0, breed = "misc/enemy_weapon"
    })
    boomerang:set_damage(enemy:get_damage())
    boomerang:set_obstacle_behavior("flying")
    local sprite = boomerang:create_sprite("enemies/misc/spirit_sword")

    --sound
    sol.timer.start(enemy, 160, function()
      if enemy:get_map():has_entities("enemy_thrown_boomerang") then
        sol.audio.play_sound("boomerang")
        return true
      end
    end)

    local m2 = sol.movement.create("straight")
    m2:set_angle(enemy:get_angle(hero))
    m2:set_max_distance(DISTANCE)
    m2:set_speed(SPEED)
    m2:set_ignore_obstacles(false)
    m2:start(boomerang, function()
      sol.timer.start(map, 200, function()
        local m3 = sol.movement.create("target")
        m3:set_target(enemy)
--        m3:set_angle(boomerang:get_angle(enemy))
        m3:set_ignore_obstacles(true)
        m3:set_speed(SPEED)
--        m3:set_max_distance(DISTANCE)
        m3:start(boomerang, function()
          boomerang:remove()
          enemy:finish_attacking()
        end)
      end)
    end)

    function m2:on_obstacle_reached()
      sol.audio.play_sound("thunk1")
      boomerang:remove()
      enemy:finish_attacking()
    end

    enemy:finish_attacking()

  end)
end


--Surround the hero with projectiles
function enemy:surround_attack()

  enemy:finish_attacking()
end


--Sweeping projectile attack
function enemy:tide_attack()

  enemy:finish_attacking()
end


--Summon blasts in a pattern on the floor
function enemy:pattern_attack()

  enemy:finish_attacking()
end


--Projectile A (I think there'll be more)
function enemy:projectile_a()

  enemy:finish_attacking()
end
