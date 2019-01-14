local general_attacks = {}

function general_attacks:initialize(enemy, properties)
    local game = enemy:get_game()
    local map = enemy:get_map()
    local hero = map:get_hero()


  --Melee Attack
  function enemy:melee_attack()
    local direction = self:get_direction4_to(hero)
    local x, y, layer = self:get_position()
    enemy:stop_movement()
    enemy:set_pushed_back_when_hurt(false)
    local wind_up_animation
    local sprite = enemy:get_sprite()
    sprite:set_animation("wind_up")
    if sprite:has_animation("melee_wind_up") then sprite:set_animation("melee_wind_up") end
    local telegraph_time = properties.wind_up_time
    if properties.melee_attack_wind_up_time then telegraph_time = properties.melee_attack_wind_up_time end
    sol.timer.start(map, telegraph_time, function()
      local m = sol.movement.create("straight")
      m:set_angle(enemy:get_angle(hero))
      m:set_speed(130)
      m:set_max_distance(8)
      m:start(enemy)

      sol.audio.play_sound(properties.melee_attack_sound)
      enemy:get_sprite():set_animation("attack", function()
        enemy:set_attack_consequence("sword", 1)
        enemy:get_sprite():set_animation("walking")
        enemy:go_random()
        enemy:check_hero()
      end)
      enemy:set_pushed_back_when_hurt(true)

      if properties.attack_sprites then
        for i=1, #properties.attack_sprites do
          local attack_sprite = enemy:create_sprite(properties.attack_sprites[i])
          attack_sprite:set_direction(direction)
          enemy:set_invincible_sprite(attack_sprite)
          enemy:set_attack_consequence_sprite(attack_sprite, "sword", "protected")
        end
      end
      enemy:set_attacking(false)
    end)
  end



  --Teleport
function enemy:teleport()
  if properties.stop_movement_while_teleporting then enemy:stop_movement() end
  if properties.invincible_while_charging_teleport then enemy:set_invincible() end
  local sprite = enemy:get_sprite()
  sprite:set_animation("wind_up")
  if sprite:has_animation("teleport_wind_up") then sprite:set_animation("teleport_wind_up") end
  local telegraph_time = properties.wind_up_time
  if properties.teleport_wind_up_time then telegraph_time = properties.teleport_wind_up_time end
  sol.timer.start(map, telegraph_time, function()
    enemy:set_can_attack(false) --temporary fix
    enemy:set_invincible()
      sprite:set_animation("phasing_out")
      sol.timer.start(map, 1000, function()
        print(sprite:get_animation())
        sprite:set_animation("teleporting")
        local m = sol.movement.create("straight")
        m:set_speed(100)
        m:set_smooth()
        m:set_max_distance(properties.teleport_length)
        m:set_angle(math.random(0, math.pi * 2))
        m:start(enemy)
        sol.timer.start(map, properties.time_phased_out, function()
          enemy:set_default_attack_consequences()
          enemy:set_can_attack() --temporary fix
          sprite:set_animation("phasing_in", function() sprite:set_animation("walking") end)
          enemy:set_attacking(false)
          enemy:go_random()
          enemy:check_hero()
        end)
    end)
  end)
end


  --Dash Attack
  function enemy:dash_attack()
    local sprite = enemy:get_sprite()
    local wind_up_animation
    sprite:set_animation("wind_up")
    if sprite:has_animation("dash_attack_wind_up") then sprite:set_animation("dash_attack_wind_up") end
    sprite:set_animation(wind_up_animation)
    local telegraph_time = properties.wind_up_time
    if properties.dash_attack_wind_up_time then telegraph_time = properties.dash_attack_wind_up_time end
    sol.timer.start(map, telegraph_time, function()
      enemy:set_attacking(false)
      sprite:set_animation("walking")
      if sprite:has_animation("dashing") then sprite:set_animation("dashing") end
      local m = sol.movement.create("straight")
      if properties.dash_attack_direction == "target_hero" then
        m:set_angle(enemy:get_angle(hero))
      else
        m:set_angle(enemy:get_movement():get_direction4())
      end
      m:set_speed(properties.dash_attack_speed)
      m:set_smooth(false)
      sol.audio.play_sound(properties.dash_attack_sound)
      if properties.invincible_while_dashing then enemy:set_invincible() end
      m:start(enemy, function()
        enemy:set_default_attack_consequences()
        enemy:set_attacking(false)
        enemy:go_random()
        enemy:check_hero()
      end) --movement callback function end
      function m:on_obstacle_reached()
        enemy:set_attacking(false)
        enemy:go_random()
        enemy:check_hero()
      end
      sol.timer.start(map, 1000, function() enemy:set_attacking(false) end) --just in case
    end)
  end



  --Summon Attack
  function enemy:summon()
    enemy:stop_movement()
    local sprite = enemy:get_sprite()
    local wind_up_animation = "wind_up"
    if sprite:has_animation("summoning_wind_up") then wind_up_animation = "summoning_wind_up" end
    sprite:set_animation(wind_up_animation)
    if properties.protected_while_summoning then enemy:set_invincible() end
    local telegraph_time = properties.wind_up_time
    if properties.summon_attack_wind_up_time then telegraph_time = properties.summon_attack_wind_up_time end
    sol.timer.start(map, telegraph_time, function()
      enemy:set_default_attack_consequences()
      sol.audio.play_sound(properties.summoning_sound)
      local i = 0
      sol.timer.start(map, properties.summon_group_delay, function()
        local herox, heroy, herol = hero:get_position()
        map:create_enemy({
          name = enemy_summon, layer = herol, x = herox, y = heroy, direction = 0, breed = properties.summon_breed, 
        })
        i = i + 1
        if i < properties.summon_group_size then return true end
      end)
      enemy:set_attacking(false)
      enemy:go_random()
      enemy:check_hero()
    end)
  end



  --Ranged Attack
  function enemy:ranged_attack()
    enemy:stop_movement()
    local sprite = enemy:get_sprite()
    sprite:set_animation("wind_up")
    if sprite:has_animation("shooting_wind_up") then sprite:set_animation("shooting_wind_up") end
    local telegraph_time = properties.wind_up_time
    if properties.ranged_attack_wind_up_time then telegraph_time = properties.ranged_attack_wind_up_time end
    sol.timer.start(map, telegraph_time, function()
      sol.audio.play_sound(properties.ranged_attack_sound)
      sprite:set_animation("shooting", function()
        going_hero = false
        enemy:go_random()
        enemy:check_hero()
      end)
      enemy:create_projectile()
    end)
  end
  function enemy:create_projectile()
    --get direction and position
    local direction = self:get_sprite():get_direction()
    local x, y, layer = self:get_position()
    local dx = {[0] = 16, [1] = 0, [2] = -16, [3] = 0}
    local dy = {[0] = 0, [1] = -16, [2] = 0, [3] = 16}
    dx, dy = dx[direction], dy[direction]
    --create projectile
    local projectile = enemy:create_enemy({
      x = dx, y = dy, layer = layer, direction = direction,
      breed = properties.projectile_breed
    })
    --Fire!
    if properties.projectile_angle == "any" then
      projectile:go(enemy:get_angle(hero))
    else
      projectile:go(direction)
    end
    --initialize projectile properties
    if properties.projectile_damage then
      projectile:set_damage(properties.projectile_damage)
    end
    if properties.projectile_split_children then
      projectile:set_num_children(properties.projectile_split_children)
    end
    if properties.projectile_num_bounces then
      projectile:set_max_bounces(properties.projectile_num_bounces)
    end
    enemy:set_attacking(false)
  end



  --Orbit Attack
  function enemy:orbit_attack()
    local sprite = enemy:get_sprite()
    local x, y, layer = enemy:get_position()
    local direction = sprite:get_direction()
    local projectiles = {}
    local NUM_PROJECTILES = properties.orbit_attack_num_projectiles
    local CHARGE_TIME = properties.orbit_attack_charge_time
    local SHOOT_DELAY = properties.orbit_attack_shoot_delay
    if properties.orbit_attack_stop_while_charging then enemy:stop_movement() end
    sprite:set_animation("wind_up")
    if sprite:has_animation("orbit_attack_wind_up") then sprite:set_animation("orbit_attack_wind_up") end
    for i=1, NUM_PROJECTILES do
      sol.timer.start(map, CHARGE_TIME/NUM_PROJECTILES * i, function()
        sol.audio.play_sound("shield")
        projectiles[i] = map:create_enemy({
          x = x, y = y, layer = layer, direction = direction,
          breed = properties.orbit_attack_projectile_breed
        })
        local m = sol.movement.create("circle")
        m:set_center(enemy)
        m:set_radius(properties.orbit_attack_radius)
        m:set_angular_speed(8)
        m:start(projectiles[i])
        if i == NUM_PROJECTILES then sprite:set_animation("walking") end
      end)
    end
    sol.timer.start(map, CHARGE_TIME + SHOOT_DELAY, function()
      sol.audio.play_sound("sword2")
      enemy:set_attacking(false)
      for i=1, #projectiles do
        if projectiles[i]:exists() and projectiles[i]:get_life() > 0 then
          sol.timer.start(map, (properties.orbit_attack_projectile_delay * i), function()
            local m = sol.movement.create("straight")
            m:set_angle(enemy:get_angle(hero))
            m:set_speed(160)
            m:set_smooth(false)
            projectiles[i]:stop_movement()
            sol.audio.play_sound(properties.orbit_attack_launch_sound or "shoot")
            m:start(projectiles[i], function() projectiles[i]:remove() end)
            function m:on_obstacle_reached() projectiles[i]:remove() end
          end)
        end
      end
    end)
  end



end

return general_attacks