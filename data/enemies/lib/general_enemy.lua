--An enemy archetype that has multiple attacks and behaviors available to it.

--Which attacks the enemy can do are set in the enemy's properties. Values are:
--has_melee_attack, melee_attack_cooldown
--has_teleport, teleport_cooldown,
--has_ranged_attack, ranged_attack_distance, ranged_attack_cooldown, projectile_breed
    --optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces
    --(make sure the projectile breed you set can take these parameters to avoid errors)
--has_summon_attack, summon_attack_distance, summon_attack_cooldown, summon_breed, summon_group_size, summon_group_delay

--Certain sprites are required for certain attacks:
--For a melee attack: "wind_up" (must loop), "attack" (must not loop)
--For a ranged attack: "shooting"
  --optional: shooting_wind_up
-- For a summon attack
--For teleporting away

--TODO - allow a to set a function as a property that is called for enemy:go_hero()
    --to allow more complex movements, such as circling the hero.

--Notes:
--If enemy has both summoning and ranged attack, both attacks are cooled down, and the hero is
--in range of both attacks, summoning has a higher priority.

--properties.must_be_aligned_to_attack is true for both shooting and melee
--TODO - break alignment requirement into separate componenets for ranged and melee attacks

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
      sol.timer.start(self, 150, function()
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
    elseif properties.has_summon_attack and can_summon and dist_hero <= properties.summon_attack_cooldown then
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
    local dx = {[0] = -16, [1] = 0, [2] = 16, [3] = 0}
    local dy = {[0] = 0, [1] = -16, [2] = 0, [3] = 16}
    dx, dy = dx[direction], dy[direction]
    attacking = true
    enemy:stop_movement()
    going_hero = false
    enemy:set_pushed_back_when_hurt(false)
    enemy:get_sprite():set_animation("wind_up")
    enemy:set_attack_consequence("sword", "protected")
    sol.timer.start(map, properties.wind_up_time, function()
      enemy:get_sprite():set_animation("attack", function()
        enemy:set_attack_consequence("sword", "protected")
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
    sol.timer.start(map, properties.wind_up_time, function()
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



  --Summon Attack
  function enemy:summon()
    local herox, heroy, herol = hero:get_position()
    local i = 0
    sol.timer.start(map, properties.summon_group_delay, function()
      map:create_enemy({
        name = enemy_summon, layer = herol, x = herox, y = heroy, direction = 0, breed = properties.summon_breed, 
      })
      i = i + 1
      if i < properties.summon_group_size then return true end
    end)
  end



end

return behavior