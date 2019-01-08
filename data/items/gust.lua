local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_gust")
  item:set_assignable(true)
end

function item:on_obtaining()
  game:set_ability("sword", 1)
end

function item:on_using()
  local hero = game:get_hero()
  local x, y, layer = hero:get_position()
  --charge for 500ms
  hero:freeze()
  hero:set_animation("charging")
  sol.audio.play_sound("cane")
  sol.timer.start(game, 1200, function()

    --create a spirit that spirals around the hero
    local spike_ball = item:get_map():create_custom_entity{
      name = "spike_ball",
      direction = 0,
      layer = layer,
      x = x,
      y = y,
      width = 16,
      height = 16,
      sprite = "entities/floating_sparkle",
      model = "damaging_sparkle"
    }
    spike_ball:set_can_traverse_ground("wall", true)
    spike_ball:set_damage(game:get_value("sword_damage") * 2)
    --also another one
    local spike_ball_2 = item:get_map():create_custom_entity{
      name = "spike_ball",
      direction = 0,
      layer = layer,
      x = x,
      y = y,
      width = 16,
      height = 16,
      sprite = "entities/spirit_1",
      model = "damaging_sparkle"
    }
    spike_ball:set_can_traverse_ground("wall", true)
    spike_ball:set_damage(game:get_value("sword_damage") * 2)
    spike_ball_2:set_can_traverse_ground("wall", true)
    spike_ball_2:set_damage(game:get_value("sword_damage") * 2)

    --create a movement for the spirits
    local m = sol.movement.create("circle")
    m:set_center(x, y)
    m:set_radius(48) --radius of spirit attack
    m:set_radius_speed(80)
    m:set_max_rotations(1)
    m:set_angular_speed(13)
    m:set_clockwise()
    local m2 = sol.movement.create("circle")
    m2:set_center(x, y)
    m2:set_radius(48) --radius of spirit attack
    m2:set_radius_speed(80)
    m2:set_max_rotations(1)
    m2:set_angular_speed(13)
    m2:set_clockwise(false)

    hero:set_sword_sprite_id("hero/gust")

    --now attack
    hero:unfreeze()
    m:start(spike_ball, function() spike_ball:remove() end)
    m2:start(spike_ball_2, function() spike_ball_2:remove() end)
    hero:start_attack()
    sol.audio.play_sound("sword_spin_attack_release")
    sol.audio.play_sound("thunk1")
    local sprite = hero:get_sprite()
    local animation = sprite:get_animation()
    function sprite:on_animation_finished()
      hero:set_sword_sprite_id("hero/sword1")
    end
    item:set_finished()
  end)
end


--  hero:set_sword_sprite_id("hero/sword2")
--  hero:set_sword_sprite_id("hero/sword1")
