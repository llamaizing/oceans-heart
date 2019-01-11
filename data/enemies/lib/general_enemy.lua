--An enemy archetype that has multiple attacks and behaviors available to it.
--properties.wind_up_time is a general length for enemies to telegraph that they're about to attack
--each attack has it's own <attack>_wind_up_time that will override this.

--Which attacks the enemy can do are set in the enemy's properties. Values are:
--has_melee_attack, melee_distance, melee_attack_cooldown, melee_attack_sound("sound effect"), attack_sprites{} (a table of sprites)
    --optional, melee_attack_wind_up_time (this is an optional property for each attack, assume it's true for all)
--has_teleport, teleport_cooldown,
--has_dash_attack, dash_attack_distance (hero distance threshold), dash_attack_cooldown,
    --dash_attack_direction ("any" or "straight"), dash_attack_length (how far the enemy will dash before stopping)
    --dash_attack_speed, dash_attack_wind_up, dash_attack_sound
    --TODO allow to set a function as a property for a callback when the dash is over or a collision with an obstacle happens
--has_ranged_attack, ranged_attack_distance, ranged_attack_cooldown, ranged_attack_sound, projectile_breed (enemy breed dat)
    --optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces
    --(make sure the projectile breed you set can take these parameters to avoid errors)
--has_summon_attack, summon_attack_distance, summon_attack_cooldown, summoning_sound,
    --summon_breed, summon_group_size, summon_group_delay, protected_while_summoning,
    --summon group size refers to, for instance, if the enemy summons 3 bolts of lightning at a time.
    --summon group delay refers to time between each of those 3 bolts of lightning. After that, cooldown will start


--Required Animations:
--walking, hurt, immobilized, shaking, wind_up (must loop)

--Certain animations are required for certain attacks:
--For a melee attack:"attack" (must not loop)
  --optional: melee_attack_wind_up
--For teleporting away:
--For a dash attack:
  --optional: "dashing", "dash_attack_wind_up"
-- For a summon attack
  --optional:summoning_wind_up
--For a ranged attack: "shooting" (must not loop)
  --optional: shooting_wind_up

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

function behavior:create(enemy, properties)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()
  local going_hero = false
  local can_melee = true
  local can_teleport = true
  local can_dash_attack = true
  local can_summon = true
  local can_shoot = true
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
    self:check_hero()
  end


  --Check hero
  function enemy:check_hero()
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
      sol.timer.start(self, 200, function()
        self:check_hero()
      end)
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
    if properties.has_melee_attack and aligned and can_melee and dist_hero <= properties.melee_distance then
      self:melee_attack()
      can_melee = false
      sol.timer.start(map, properties.melee_attack_cooldown, function() can_melee = true end)        
    elseif properties.has_teleport and dist_hero <= properties.teleport_distance then
      print("would teleport")
      can_teleport = false
      sol.timer.start(map, properties.teleport_cooldown, function() can_teleport = true end)
    elseif properties.has_dash_attack and can_dash_attack and dist_hero <= properties.dash_attack_distance then
      print("would dash attack")
      can_dash_attack = false
      sol.timer.start(map, properties.dash_attack_cooldown, function() can_dash_attack = true end)
    elseif properties.has_summon_attack and can_summon and dist_hero <= properties.summon_attack_distance then
      self:summon()
      can_summon = false
      sol.timer.start(map, properties.summon_attack_cooldown, function() can_summon = true end)
    elseif properties.has_ranged_attack and aligned and can_shoot and dist_hero <= properties.ranged_attack_distance then
      self:ranged_attack()
      can_shoot = false
      sol.timer.start(map, properties.ranged_attack_cooldown, function() can_shoot = true end)
    end



  end





  --Melee Attack
  function enemy:melee_attack()
    local direction = self:get_sprite():get_direction()
    local x, y, layer = self:get_position()
    attacking = true
    enemy:stop_movement()
    going_hero = false
    enemy:set_pushed_back_when_hurt(false)
    local wind_up_animation
    local sprite = enemy:get_sprite()
    if sprite:has_animation("melee_wind_up") then
      wind_up_animation = sprite:get_animation("melee_wind_up")
    else wind_up_animation = sprite:get_animation("wind_up")
    end
    sprite:set_animation(wind_up_animation)
    enemy:set_attack_consequence("sword", "protected")
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



  --Dash Attack
  function enemy:dash_attack()
    local sprite = enemy:get_sprite()
    local wind_up_animation
    if sprite:has_animation("dash_attack_wind_up") then
      wind_up_animation = sprite:get_animation("dash_attack_wind_up")
    else wind_up_animation = sprite:get_animation("wind_up")
    end
    sprite:set_animation(wind_up_animation)
    local telegraph_time = properties.wind_up_time
    if properties.dash_attack_wind_up_time then telegraph_time = properties.dash_attack_wind_up_time end
    sol.timer.start(map, telegraph_time, function()
      sprite:set_animation("walking")
      if sprite:has_animation("dashing") then sprite:set_animation("dashing") end
      local m = sol.movement.create("straight")
      if properties.dash_attack_direction == "any" then
        m:set_angle(enemy:get_angle(hero))
      else
        m:set_angle(sprite:get_direction())
      end
      m:set_speed(properties.dash_attack_speed)
      m:set_smooth(false)
      sol.audio.play_sound(properties.dash_attack_sound)
      m:start(enemy, function()
        attacking = false
        enemy:go_random()
        enemy:check_hero()
      end) --movement callback function end
      function m:on_obstacle_reached()
        attacking = false
        enemy:go_random()
        enemy:check_hero()
      end
    end)
  end



  --Summon Attack
  function enemy:summon()
    attacking = true
    enemy:stop_movement()
    going_hero = false
    local sprite = enemy:get_sprite()
    local wind_up_animation
    if sprite:has_animation("summoning_wind_up") then
      wind_up_animation = sprite:get_animation("summoning_wind_up")
    else wind_up_animation = sprite:get_animation("wind_up")
    end
    sprite:set_animation(wind_up_animation)
    if properties.protected_while_summoning then enemy:set_invincible() end
    local telegraph_time = properties.wind_up_time
    if properties.summon_attack_wind_up_time then telegraph_time = properties.summon_attack_wind_up_time end
    sol.timer.start(map, telegraph_time, function()
      enemy:set_default_attack_consequences()
      sol.audio.play_sound(properties.summoning_sound)
      local herox, heroy, herol = hero:get_position()
      local i = 0
      sol.timer.start(map, properties.summon_group_delay, function()
        map:create_enemy({
          name = enemy_summon, layer = herol, x = herox, y = heroy, direction = 0, breed = properties.summon_breed, 
        })
        i = i + 1
        if i < properties.summon_group_size then return true end
      end)
    end)
    attacking = false
    enemy:go_random()
    enemy:check_hero()
  end



  --Ranged Attack
  function enemy:ranged_attack()
    attacking = true
    enemy:stop_movement()
    going_hero = false
    local sprite = enemy:get_sprite()
    local wind_up_animation
    if sprite:has_animation("shooting_wind_up") then
      wind_up_animation = sprite:get_animation("shooting_wind_up")
    else wind_up_animation = sprite:get_animation("wind_up")
    end
    sprite:set_animation(wind_up_animation)
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


end

return behavior