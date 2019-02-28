  local behavior = {}




function behavior:create(enemy, properties)

  local dist_hero
  local can_attack = true
  local going_hero = false

  -- Set default properties.
  if properties.life == nil then
    properties.life = 2
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 48
  end
  if properties.size_x == nil then
    properties.size_x = 16
  end
  if properties.size_y == nil then
    properties.size_y = 16
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.pushed_when_hurt == nil then
    properties.pushed_when_hurt = true
  end
  if properties.push_hero_on_sword == nil then
    properties.push_hero_on_sword = false
  end
  if properties.ignore_obstacles == nil then
    properties.ignore_obstacles = false
  end
  if properties.detection_distance == nil then
    properties.detection_distance = 900
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.projectile_breed == nil then
    properties.projectile_breed = "misc/octorok_stone"
  end
  if properties.attack_frequency == nil then
    properties.attack_frequency = 3500
  end
  if properties.explosion_consequence == nil then
    properties.explosion_consequence = 1
  end
  if properties.fire_consequence == nil then
    properties.fire_consequence = 1
  end
  if properties.sword_consequence == nil then
    properties.sword_consequence = 1
  end
  if properties.arrow_consequence == nil then
    properties.arrow_consequence = 1
  end
  if properties.movement_create == nil then
    properties.movement_create = function()
      local m = sol.movement.create("random_path")
      return m
    end
  end
  if properties.must_be_aligned_to_attack == nil then
    properties.must_be_aligned_to_attack = false
  end
  if properties.melee_distance == nil then
    properties.melee_distance = 32
  end
  if properties.wind_up_time == nil then
    properties.wind_up_time = 400
  end
  if properties.melee_sound == nil then
    properties.melee_sound = "sword3"
  end
  if properties.vulnerable_in_windup == nil then
    properties.vulnerable_in_windup = false
  end
  if properties.create_enemy_on_attack == nil then
    properties.create_enemy_on_attack = false
  end


  function enemy:on_created()

    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self:create_sprite(properties.sprite)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_obstacle_behavior(properties.obstacle_behavior)
    self:set_size(properties.size_x, properties.size_y)
    self:set_origin(properties.size_x / 2, properties.size_y - 3)
    self:set_attack_consequence("explosion", properties.explosion_consequence)
    self:set_attack_consequence("fire", properties.fire_consequence)
    self:set_attack_consequence("sword", properties.sword_consequence)
    self:set_attack_consequence("arrow", properties.arrow_consequence)
    if properties.dying_sprite then self:set_dying_sprite_id(properties.dying_sprite) end
  end

  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end


  function enemy:on_obstacle_reached(movement)
    if not going_hero then
      self:go_random()
      self:check_hero()
    end
  end

  function enemy:on_restarted()
	  local map = self:get_map()
	  local hero = map:get_hero()
    self:go_random()
    self:check_hero()
	  can_attack = true
    dist_hero = enemy:get_distance(hero)

	  sol.timer.start(enemy, 100, function()

			local hero_x, hero_y = hero:get_position()
			local x, y = enemy:get_center_position()
      local aligned

      --check if the enemy will attack
			if can_attack == true and dist_hero <= properties.melee_distance then

        --check if hero is aligned, if necessary
        if properties.must_be_aligned_to_attack == true then
          --if alignment is necessary, check for alignment and distance
          if ((math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16))
          and dist_hero < properties.detection_distance then
            aligned = true
          end
        else
          --otherwise, just check for distance
          if dist_hero < properties.detection_distance then
            aligned = true
          end 
        end

        --if the hero is aligned, or doesn't need to be, attack
        if aligned == true then
  			  self:attack()
  				can_attack = false
  				sol.timer.start(enemy, properties.attack_frequency, function()
  				  can_attack = true
  				end)
        end

---				  end
			end


			return true  -- Repeat the timer.

	  end)--end of timer argument

  end--end of on:restarted function


  function enemy:go_random()
    going_hero = false
    local m = properties.movement_create()
    if m == nil then
      -- No movement.
      self:get_sprite():set_animation("stopped")
      m = self:get_movement()
      if m ~= nil then
        -- Stop the previous movement.
        m:stop()
      end
    else
      m:set_speed(properties.normal_speed)
      m:set_ignore_obstacles(properties.ignore_obstacles)
      m:start(self)
      self:get_sprite():set_animation("walking")
    end
  end


  function enemy:check_hero()

    local hero = self:get_map():get_entity("hero")
    local _, _, layer = self:get_position()
    local _, _, hero_layer = hero:get_position()
    local near_hero =
        (layer == hero_layer or enemy:has_layer_independent_collisions()) and
        self:get_distance(hero) < properties.detection_distance and
        self:is_in_same_region(hero)
    dist_hero = self:get_distance(hero)

    if near_hero and not going_hero then
      self:go_hero()
    elseif not near_hero and going_hero then
      self:go_random()
    end

-- This line causes problems for some reason I don't yet understand.
--    sol.timer.stop_all(self)
    sol.timer.start(self, 100, function() self:check_hero() end)
  end

  function enemy:go_hero()
    going_hero = true
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(self)
    self:get_sprite():set_animation("walking")
  end



	function enemy:attack()
    --first, check if the hero is in the same region
	  local map = enemy:get_map()
	  local hero = map:get_hero()
	  if not enemy:is_in_same_region(hero) then
  		return true  -- Repeat the timer.
	  end

	  local sprite = enemy:get_sprite()
	  local x, y, layer = enemy:get_position()
	  local direction = sprite:get_direction()

	  sprite:set_animation("wind_up")
    if properties.vulnerable_in_windup == false then enemy:set_attack_consequence("sword", "protected") end
	  enemy:stop_movement()
    --charging phase
	  sol.timer.start(enemy, properties.wind_up_time, function()
      sol.audio.play_sound(properties.melee_sound)
  	  sprite:set_animation("attack")

      function sprite:on_animation_finished()
        sprite:set_animation("walking")
        enemy:set_attack_consequence("sword", properties.sword_consequence)
        enemy:go_random()
        enemy:check_hero()
      end

	  end) --end of wind up timer

	end --end of attack function

end

return behavior