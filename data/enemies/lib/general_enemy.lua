--An enemy archetype that has multiple attacks and behaviors available to it.
--properties.wind_up_time is a general length for enemies to telegraph that they're about to attack
--each attack has it's own <attack>_wind_up_time that will override this.

--Which attacks the enemy can do are set in the enemy's properties. Values are:
--has_melee_attack, melee_distance, melee_attack_cooldown, melee_attack_sound("sound effect"), attack_sprites{} (a table of sprites)
    --optional, melee_attack_wind_up_time (this is an optional property for each attack, assume it's true for all)
--has_teleport, teleport_distance, teleport_cooldown,invincible_while_charging_teleport, teleport_length (how far enemy travels)
  --time_phased_out, stop_movement_while_teleporting
  --optional: teleport_wind_up_time (assume this for all attacks, again)
--has_dash_attack, dash_attack_distance (hero distance threshold), dash_attack_cooldown,
    --dash_attack_direction ("target_hero" or "straight"), dash_attack_length (how far the enemy will dash before stopping)
    --dash_attack_speed, dash_attack_wind_up, dash_attack_sound, invincible_while_dashing(bool)
    --TODO allow to set a function as a property for a callback when the dash is over or a collision with an obstacle happens
--has_ranged_attack, ranged_attack_distance, ranged_attack_cooldown, ranged_attack_sound,
    --projectile_breed, projectile_angle ("any", or "straight")
    --optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces
    --(make sure the projectile breed you set can take these parameters to avoid errors)
    --(the projectile breed also requires an enemy:go(angle) function which is called right after it's created)
--has_summon_attack, summon_attack_distance, summon_attack_cooldown, summoning_sound,
    --summon_breed, summon_group_size, summon_group_delay, protected_while_summoning,
    --summon group size refers to, for instance, if the enemy summons 3 bolts of lightning at a time.
    --summon group delay refers to time between each of those 3 bolts of lightning. After that, cooldown will start
--has_orbit_attack, orbit_attack_distance, orbit_attack_cooldown, orbit_attack_sound, orbit_attack_num_projectiles
      --orbit_attack_charge_time, orbit_attack_shoot_delay, orbit_attack_projectile_delay, orbit_attack_projectile_breed,
      --orbit_attack_radius, orbit_attack_launch_sound, orbit_attack_stop_while_charging
--For a custom attack (TODO - debug custom attack, which sometimes results in the enemy stopping the check_hero() loop)
      --properties.has_custom_attack - For this script to check requirements, and if met, start the attack
      --properties.custom_attack_cooldown - cooldown in ms for custom attack
      --properties.custom_attack_requirements - function that returns a boolean to check if custom attack can be done
        --this should check for distance from hero, alignment, etc.
      --properties.custom_attack - function that determines what happens.
        --This function must take a callback function as an argument for what to do when attack is finished.


--Required Animations:
--walking, hurt, immobilized, shaking, wind_up (must loop)

--Certain animations are required for certain attacks:
--For a melee attack:"attack" (must not loop)
  --optional: melee_attack_wind_up
--For teleporting away: "phasing_out (must not loop)", "phasing_in (must not loop)", "teleporting"
  --optional: teleport_wind_up
--For a dash attack:
  --optional: "dashing", "dash_attack_wind_up"
-- For a summon attack
  --optional:summoning_wind_up
--For a ranged attack: "shooting" (must not loop)
  --optional: shooting_wind_up
--For an orbit attack
  --optional: "orbit_attack_wind_up"

--TODO - allow to set a function as a property that is called for enemy:go_hero()
    --to allow more complex movements, such as circling the hero.

--Notes:
--If enemy has both summoning and ranged attack, both attacks are cooled down, and the hero is
--in range of both attacks, summoning has a higher priority. Really, this is and issue for any
--two or more attacks with the same range and cooldown status. The hierarchy of priority is:
--Melee > Teleport > Dash Attack > Summon Attack > Ranged Attack

--properties.must_be_aligned_to_attack is true for both shooting and melee
--TODO - break alignment requirement into separate componenets different attacks

--Local value attacking is used for all attacks to keep the enemy from trying to do an attack while already executing one.

--Cooldowns are set to map timers so as not to be reset when the enemy is damaged.

local behavior = {}

local normal_functions = require("enemies/lib/normal_functions")
local movement_patterns = require("enemies/lib/movement_patterns")

function behavior:create(enemy, properties)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()
  local going_hero = false
  local can_custom_attack = true
  local can_melee = true
  local can_teleport = true
  local can_dash_attack = true
  local can_summon = true
  local can_shoot = true
  local can_orbit_attack = true
  local attacking = false

  --initialize universal enemy stuff:
  normal_functions:set(enemy, properties)
  --this is pretty notmal too, but needs check_hero()
  function enemy:on_obstacle_reached(movement)
    if not going_hero then
      self:go_random()
      self:check_hero()
    end
  end


  --RESTART
  function enemy:on_restarted()
    self:get_sprite():set_animation("walking")
    going_hero = false
    self:go_random()
    sol.timer.start(self, 200, function() enemy:check_hero() return true end)
  end

--local n=0
  --Check hero
  function enemy:check_hero()
--print("checking"..n) n=n+1 print("attacking: ")print(attacking) print("going hero: ")print(going_hero)
    if not attacking then
      local near_hero = self:is_near_hero()
      if near_hero and not going_hero then
        going_hero = true
        self:go_hero()
      elseif not near_hero and going_hero then
        going_hero = false
        self:go_random()
      end
      --and also decide if we should attack or something
      if going_hero then self:check_to_attack() end
    end
  end


  --Check to Attack
  function enemy:check_to_attack()
    --check if hero is aligned, if necessary
    local aligned = true
    local dist_hero = self:get_distance(hero)
    if properties.must_be_aligned_to_attack then
      if not ((math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16)) then aligned = false end
    end

    --choose what attack to do:
    -- if properties.has_custom_attack and can_custom_attack and properties.custom_attack_requirements then
    --   attacking = true
    --   going_hero = false
    --   can_custom_attack = false
    --   local f = properties.custom_attack
    --   f(function() attacking = false enemy:go_random() enemy:check_hero() end)
    --   sol.timer.start(map, properties.custom_attack_cooldown, function() can_custom_attack = true end)

    if properties.has_melee_attack and aligned and can_melee and dist_hero <= properties.melee_distance then
      attacking = true
      going_hero = false
      self:melee_attack()
      can_melee = false
      sol.timer.start(map, properties.melee_attack_cooldown, function() can_melee = true end)

    elseif properties.has_teleport and can_teleport and dist_hero <= properties.teleport_distance then
      attacking = true
      going_hero = false
      self:teleport()
      can_teleport = false
      sol.timer.start(map, properties.teleport_cooldown, function() can_teleport = true end)

    elseif properties.has_dash_attack and can_dash_attack and dist_hero <= properties.dash_attack_distance then
      attacking = true
      going_hero = false
      self:dash_attack()
      can_dash_attack = false
      sol.timer.start(map, properties.dash_attack_cooldown, function() can_dash_attack = true end)

    elseif properties.has_summon_attack and can_summon and dist_hero <= properties.summon_attack_distance then
      attacking = true
      going_hero = false
      self:summon()
      can_summon = false
      sol.timer.start(map, properties.summon_attack_cooldown, function() can_summon = true end)

    elseif properties.has_ranged_attack and aligned and can_shoot and dist_hero <= properties.ranged_attack_distance then
      attacking = true
      going_hero = false
      self:ranged_attack()
      can_shoot = false
      sol.timer.start(map, properties.ranged_attack_cooldown, function() can_shoot = true end)

    elseif properties.has_orbit_attack and can_orbit_attack and dist_hero <= properties.orbit_attack_distance then
      attacking = true
      going_hero = false
      self:orbit_attack()
      can_orbit_attack = false
      sol.timer.start(map, properties.orbit_attack_cooldown, function() can_orbit_attack = true end)
    end

  end





  --Melee Attack
  function enemy:melee_attack()
    local direction = self:get_sprite():get_direction()
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
      attacking = false
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
          attacking = false
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
      attacking = false
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
        attacking = false
        enemy:go_random()
        enemy:check_hero()
      end) --movement callback function end
      function m:on_obstacle_reached()
        attacking = false
        enemy:go_random()
        enemy:check_hero()
      end
      sol.timer.start(map, 1000, function() attacking = false end) --just in case
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
      attacking = false
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
    attacking = false
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
      attacking = false
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


end --end of bahavior:create() fuction
return behavior