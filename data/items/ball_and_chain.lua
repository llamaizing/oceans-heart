local item = ...
local game = item:get_game()

local NUM_LINKS = 7
local MIN_RADIUS = 2
local RADIUS = 48
local RAIUS_SPEED = 250
local MAX_ROTATIONS = 3
local ANGULAR_SPEED = 13
local CHARGING_TIME = 500


-- Event called when the game is initialized.
function item:on_started()
  item:set_savegame_variable("possession_ball_and_chain")
  item:set_assignable(true)
end

-- Event called when the hero is using this item.
function item:on_using()
  local map = item:get_map()
  local hero = map:get_hero()
  local hero_dir = hero:get_direction()
--  hero:freeze()
  local summoning_state = sol.state.create()
  summoning_state:set_can_control_movement(false)
  summoning_state:set_can_be_hurt(true)
  summoning_state:set_can_use_sword(false)
  summoning_state:set_can_use_item(false)
  summoning_state:set_can_interact(false)
  summoning_state:set_can_grab(false)
  summoning_state:set_can_pick_treasure(false)
  hero:start_state(summoning_state)

  local x, y, layer = hero:get_position()
  local links = {}
  local link_movements = {}
  
  --now move x or y depending on hero facing direction
  local start_x = x
  local start_y = y
  if hero_dir == 0 then start_x = x - 16 elseif hero_dir == 1 then start_y = y + 16 elseif hero_dir == 2 then start_x = x + 16 elseif hero_dir == 3 then start_y = y - 16 end

  local flail_x = x
  local flail_y = y
  local start_angle = 0
  if hero_dir == 0 then flail_x = x + 16 start_angle = 0
  elseif hero_dir == 1 then
    flail_y = y - 16
    start_angle = math.pi / 2
  elseif hero_dir == 2 then
    flail_x = x - 16
    start_angle = math.pi
  elseif hero_dir == 3 then
    flail_y = y + 16
    start_angle = 3 * math.pi / 2
  end

  --create chain links
  for i=1, NUM_LINKS do
    links[i] = map:create_custom_entity{
      name = "flail_chain_link",
      direction = 0,
      layer = layer,
      x = start_x,
      y = start_y,
      width = 8,
      height = 8,
      sprite = "entities/chain_link",
      model = "damaging_sparkle"
    }
    link_movements[i] = sol.movement.create("circle")
    link_movements[i]:set_center(flail_x, flail_y)
    link_movements[i]:set_ignore_obstacles()
    link_movements[i]:set_radius(MIN_RADIUS)
    link_movements[i]:set_radius_speed(RAIUS_SPEED)
    link_movements[i]:set_max_rotations(MAX_ROTATIONS)
    link_movements[i]:set_angular_speed(ANGULAR_SPEED)
    if hero_dir == 0 or hero_dir == 3 then link_movements[i]:set_clockwise() end
    links[i]:set_is_flail(true)
  end

  --create the spike ball
  local spike_ball = map:create_custom_entity{
    name = "flail_spike_ball",
    direction = 0,
    layer = layer,
    x = start_x,
    y = start_y,
    width = 8,
    height = 8,
    sprite = "entities/spike_ball",
    model = "damaging_sparkle"
  }
  spike_ball:set_damage(game:get_value("sword_damage") + game:get_value("sword_damage")/2)
  spike_ball:set_is_flail(true)


  --create a movement for the flail
  local m = sol.movement.create("circle")
  m:set_center(flail_x, flail_y)
  m:set_ignore_obstacles()
--  m:set_angle_from_center(start_angle)
  m:set_radius(MIN_RADIUS)
  m:set_radius_speed(RAIUS_SPEED)
  m:set_max_rotations(MAX_ROTATIONS)
  m:set_angular_speed(ANGULAR_SPEED)
  if hero_dir == 0 or hero_dir == 3 then m:set_clockwise() end



  --START CHARGING (because this is too powerful to not charge)
  hero:set_animation("charging")
  sol.timer.start(game, CHARGING_TIME, function()
    --AND GO! ATTACK!
    local circling = true
    sol.timer.start(map, 2, function()
      if circling then
        sol.audio.play_sound("flail_swing")
        return 450
      end
    end)
    --Start the movements and change the hero's animation
    hero:set_animation("hookshot")
    m:start(spike_ball, function() spike_ball:remove() hero:unfreeze() circling = false end)
    for i=1, NUM_LINKS do
      link_movements[i]:start(links[i], function() links[i]:remove() end)
      link_movements[i]:set_radius(RADIUS / NUM_LINKS * i)
    end
    m:set_radius(RADIUS)
  end)


  --end the movement if it doesn't collide with something
  function m:on_finished()
    hero:unfreeze()
    circling = false
    spike_ball:remove()
    for i=1, NUM_LINKS do links[i]:remove() end
    item:set_finished()
  end

  --if the movement collides with something
  local can_play_sound = true
  function m:on_obstacle_reached()
    if can_play_sound then
      sol.audio.play_sound("sword_tapping")
      can_play_sound = false
      sol.timer.start(game, 500, function() can_play_sound = true end)
    end

    --to cause a fucking explosion if the variant is 2 or more
    if item:get_variant() >= 2 then
      local spike_x, spike_y, spike_layer = spike_ball:get_position()
      map:create_explosion{layer = spike_layer, x = spike_x, y = spike_y}
    end
  end
end
