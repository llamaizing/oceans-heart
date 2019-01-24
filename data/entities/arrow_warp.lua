-- Arrow shot by the bow.
-- Replaces the built-in one to allow silver arrows.

local arrow = ...
local game = arrow:get_game()
local map = arrow:get_map()
local hero = map:get_hero()
local direction = hero:get_direction()
local bow = game:get_item("bow")
local force
local sprite_id
local sprite
local enemies_touched = {}
local entity_reached
local entity_reached_dxy
local flying
local initial_pos_x
local initial_pos_y

local MAGIC_COST = 25
local enough_magic

function arrow:on_created()
  if game:get_magic() > MAGIC_COST then
    enough_magic = true
    game:remove_magic(MAGIC_COST)
  else enough_magic = false
  end

  local direction = arrow:get_direction()
  local horizontal = direction % 2 == 0
  if horizontal then
    arrow:set_size(16, 8)
    arrow:set_origin(8, 4)
  else
    arrow:set_size(8, 16)
    arrow:set_origin(4, 8)
  end

  local bow = game:get_item("bow")
  force = bow.get_force and bow:get_force() or 1

end

-- Traversable rules.
arrow:set_can_traverse("crystal", true)
arrow:set_can_traverse("crystal_block", true)
arrow:set_can_traverse("hero", true)
arrow:set_can_traverse("jumper", true)
arrow:set_can_traverse("stairs", false)
arrow:set_can_traverse("stream", true)
arrow:set_can_traverse("switch", true)
arrow:set_can_traverse("teletransporter", true)
arrow:set_can_traverse_ground("deep_water", true)
arrow:set_can_traverse_ground("shallow_water", true)
arrow:set_can_traverse_ground("hole", true)
arrow:set_can_traverse_ground("lava", true)
arrow:set_can_traverse_ground("prickles", true)
arrow:set_can_traverse_ground("low_wall", true)
arrow.apply_cliffs = true

-- Triggers the animation and sound of the arrow reaching something
-- and removes the arrow after some delay.
local function attach_to_obstacle()

  flying = false
  sprite:set_animation("reached_obstacle")
  sol.audio.play_sound("arrow_hit")
  arrow:stop_movement()

  sol.timer.start(map, 1500, function()
    arrow:remove()
  end)

end


local function warp_hero(entity)
  if enough_magic then
  initial_pos_x, initial_pos_y = entity:get_position()
    if entity:get_type() == "enemy" then entity:stop_movement() end
    sol.audio.play_sound("warp")
    hero:freeze()
    hero:set_animation("arrow_warping", function()
      local dx = {[0] = 24, [1] = 0, [2] = -24, [3] = 0}
      local dy = {[0] = 0, [1] = -24, [2] = 0, [3] = 24}
      local dir = entity:get_direction4_to(hero)
      dx, dy = dx[dir], dy[dir]
      -- local m = sol.movement.create("target")
      -- m:set_target(initial_pos_x + dx, initial_pos_y + dy)
      -- m:set_speed(200)
      -- m:set_smooth()
      local m = sol.movement.create("straight")
      m:set_angle(hero:get_angle(entity))
      m:set_max_distance(entity:get_distance(hero))
      m:set_speed(200)
      
      local warping_state = sol.state.create()
      warping_state:set_visible(false)
      warping_state:set_can_traverse(true)
--      warping_state:set_can_traverse_ground("wall", true)
--      warping_state:set_can_traverse_ground("low_wall", true)
      warping_state:set_can_traverse_ground("deep_water", true)
      warping_state:set_can_traverse_ground("hole", true)
      warping_state:set_can_traverse_ground("prickles", true)
      warping_state:set_can_traverse_ground("lava", true)
      warping_state:set_can_control_movement(false)
      warping_state:set_can_be_hurt(false)
      warping_state:set_can_use_sword(false)
      warping_state:set_can_use_item(false)
      warping_state:set_can_interact(false)
      warping_state:set_can_grab(false)
      warping_state:set_can_pick_treasure(false)
      warping_state:set_can_use_stairs(false)
      warping_state:set_can_use_jumper(false)
      hero:start_state(warping_state)

      m:start(hero, function() hero:unfreeze() end)
    end)
  else --not enough magic
    sol.audio.play_sound("no")
  end
end


-- Attaches the arrow to an entity and make it follow it.
local function attach_to_entity(entity)

  if entity_reached ~= nil then
    -- Already attached.
    return
  end

  -- Stop flying.
  attach_to_obstacle()

  -- Make the arrow follow the entity reached when it moves.
  entity_reached = entity
  local entity_reached_x, entity_reached_y = entity_reached:get_position()
  local x, y = arrow:get_position()
  entity_reached_dxy = { entity_reached_x - x, entity_reached_y - y }

  sol.timer.start(arrow, 10, function()

    if not entity_reached:exists() then
      arrow:remove()
      return false
    end

    if entity_reached:get_type() == "enemy" then
      local enemy_sprite = entity_reached:get_sprite()
      if entity_reached:get_life() <= 0 and
          enemy_sprite ~= nil and
          enemy_sprite:get_animation() ~= "hurt" then
        -- Dying animation of an enemy: don't keep the arrow.
        arrow:remove()
        return false
      end
    end

    x, y = entity_reached:get_position()
    x, y = x - entity_reached_dxy[1], y - entity_reached_dxy[2]
    arrow:set_position(x, y)

    return true
  end)
end


-- Hurt enemies.
arrow:add_collision_test("sprite", function(arrow, entity)

  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local arrow_reaction = enemy:get_attack_consequence_sprite(sprite, "arrow")
    attach_to_entity(enemy)
    if arrow_reaction ~= "protected" and arrow_reaction ~= "ignored" then
      if enemy:get_life() - game:get_value("bow_damage") <= 0 then
        --warp hero to enemy's location
        warp_hero(entity)
      end
      bow_damage = game:get_value("bow_damage")
     enemy:hurt(bow_damage)
    end

  end
end)



--NOTE TO SELF: The acceptable sprites for switchs are hard coded in. If you make a new switch sprite, make sure you add it
--to the list of acceptable sprites for switches to have.

arrow:add_collision_test("overlapping", function(arrow, entity)

  local entity_type = entity:get_type() --this should be a string

  if entity_type == "crystal" then
    --activate the crystal
    if flying then
      sol.audio.play_sound("switch")
      map:change_crystal_state()
      attach_to_entity(entity)
    end --end of if flying

  elseif entity_type == "switch" then
    --activate the switch you hit if it's solid or arrow-type
    local switch = entity
    local sprite = switch:get_sprite()
    --check if the switch's sprite is the right type for activating
    if flying and sprite ~= nil and
    (sprite:get_animation_set() == "entities/switch_solid" or "entities/switch_lever_1" or "entities/switch_arrow") then
 
      --if it's off, turn it on. Or vice-versa.
      if not switch:is_activated() then
        sol.audio.play_sound("switch")
        switch:set_activated(true)
      else
        sol.audio.play_sound("switch")
        switch:set_activated(false)
      end
      attach_to_entity(entity)

    end --end of if flying and if the switch's sprite is an accepted type for activation

  end  --end of what type of entity you hit

end) --end of collision test callback function




function arrow:get_sprite_id()
  return sprite_id
end

function arrow:set_sprite_id(id)
  sprite_id = id
end

function arrow:get_force()
  return force
end

function arrow:set_force(f)
  force = f
end

function arrow:go()

  local sprite_id = arrow:get_sprite_id()
  sprite = arrow:create_sprite(sprite_id)
  sprite:set_animation("flying")
  sprite:set_direction(direction)

  local movement = sol.movement.create("straight")
  local angle = direction * math.pi / 2
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:set_max_distance(500)
  movement:start(arrow)
  flying = true
end

function arrow:on_obstacle_reached()

  attach_to_obstacle()
end