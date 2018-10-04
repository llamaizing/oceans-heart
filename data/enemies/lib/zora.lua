local behavior = {}

--This enemy is like Zelda's Zora. It is similar to the underground random enemy type, in that it moves randomly aboveground for some time, then dives below ground (or water, set obstacle properties appropriately) to move randomly for some time. The difference is that when this enemy pops up, it shoots at the hero if the hero is close enough.

function behavior:create(enemy, properties)

  local children = {}
  local map = enemy:get_map()
  local hero = map:get_hero()
  

  -- Set default properties.
  if properties.size_x == nil then
    properties.size_x = 16
  end
  if properties.size_y == nil then
    properties.size_y = 16
  end
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
    properties.detection_distance = 140
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.movement_create == nil then
    properties.movement_create = function()
      local m = sol.movement.create("random_path")
      return m
    end
  end
  if properties.time_underground == nil then
    properties.time_underground = 1000
  end
  if properties.time_aboveground == nil then
    properties.time_aboveground = 1000
  end
  if properties.burrow_deviation == nil then
    properties.burrow_deviation = 4000
  end
  if properties.burrow_sound == nil then
    properties.burrow_sound = "burrow1"
  end
  if properties.projectile_breed == nil then
    properties.projectile_breed = "misc/zora_fire"
  end
  

--create enemy properties
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

  end


  function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end


	local previous_on_removed = enemy.on_removed
	function enemy:on_removed()

	  if previous_on_removed then
		previous_on_removed(enemy)
	  end

	  for _, child in ipairs(children) do
		child:remove()
	  end
	end


  function enemy:on_obstacle_reached(movement)
      self:go_random()
  end

  function enemy:on_restarted()
    self:go_random()
    sol.timer.stop_all(self)
    sol.timer.start(self, (properties.time_aboveground), function() self:burrow_down() end)
    
  end


  function enemy:go_random()
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
    end
  end

  function enemy:burrow_down()
    self:get_sprite():set_animation("burrowing")
    if enemy:get_distance(hero) < properties.detection_distance then sol.audio.play_sound(properties.burrow_sound) end
    sol.timer.start(self, 400, function() self:go_underground() end)
  end

  function enemy:burrow_up()
    self:get_sprite():set_animation("burrowing")
    if enemy:get_distance(hero) < properties.detection_distance then sol.audio.play_sound(properties.burrow_sound) end
    sol.timer.start(self, 1000, function() self:go_aboveground() end)
  end

  function enemy:go_underground()
    self:get_sprite():set_animation("underground")
    self:set_can_attack(false)
    sol.timer.start(self, (properties.time_underground + math.random(properties.burrow_deviation)), function() self:burrow_up() end)
    
  end

  function enemy:go_aboveground()
    self:set_can_attack(true)
    self:get_sprite():set_animation("walking")
    if enemy:get_distance(hero) < properties.detection_distance then self:shoot() end
    self:restart()
  end


	function enemy:shoot()
	  local sprite = enemy:get_sprite()
	  local x, y, layer = enemy:get_position()
	  local direction = sprite:get_direction()

	  -- Where to create the projectile.
	  local dxy = {
		{  8,  -4 },
		{  0, -13 },
		{ -8,  -4 },
		{  0,   0 },
	  }

	  sprite:set_animation("shooting")
--	  enemy:stop_movement()
		sol.audio.play_sound("stone")
		local stone = enemy:create_enemy({
		  breed = properties.projectile_breed,
		  x = dxy[direction + 1][1],
		  y = dxy[direction + 1][2],
		})
		children[#children + 1] = stone
--		stone:go(direction)
	  sprite:set_animation("walking")
    self:restart()
	end



end

return behavior