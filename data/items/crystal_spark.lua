local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_crystal_spark")
  item:set_assignable(true)
end

function item:on_obtaining()
  game:set_ability("sword", 1)
end

function item:on_using()
  local map = item:get_map()
  local hero = game:get_hero()
  local x, y, layer = hero:get_position()

  local PILLAR_RANGE = 125

  --charge for 500ms
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

  hero:set_animation("charging")
  sol.audio.play_sound("cane")
  sol.timer.start(game, 1200, function()

    --summon some stuff to hurt enemies
    local flame_pillars = {}
    for i = 1, 8 do
      flame_pillars[i] = map:create_custom_entity{
      name = "friendly_fire",
      direction = 0,
      layer = layer,
      x = x,
      y = y,
      width = 16,
      height = 16,
      sprite = "entities/flame_pillar",
      model = "damaging_sparkle"
      }
      flame_pillars[i]:set_damage((game:get_value("sword_damage") * 2) or 10)
--      flame_pillars[i]:set_can_traverse_ground("wall", true)
    end

    local movements = {}
    for i = 1, 8 do
      movements[i] = sol.movement.create("straight")
      movements[i]:set_speed(130)
      movements[i]:set_angle((math.pi/4) * i)
      movements[i]:set_max_distance(PILLAR_RANGE)
    end

    --now attack
    --launch pillars
    for i=1, 8 do
      movements[i]:start(flame_pillars[i], function() flame_pillars[i]:remove() end)
    end
    sol.timer.start(game, 2000, function()
      for i=1,8 do flame_pillars[i]:remove() end
    end)

    hero:set_sword_sprite_id("hero/gust")
--    hero:unfreeze()
    hero:start_attack()
    sol.audio.play_sound("sword_spin_attack_release")
    sol.audio.play_sound("thunk1")
    local sprite = hero:get_sprite()
    local animation = sprite:get_animation()
    function sprite:on_animation_finished()
      hero:set_sword_sprite_id("hero/sword1")
    end
    hero:unfreeze()
    item:set_finished()


  end) --end of warmup timer callback
end


--  hero:set_sword_sprite_id("hero/sword2")
--  hero:set_sword_sprite_id("hero/sword1")
