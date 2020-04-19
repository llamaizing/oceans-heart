require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_spear")
  item:set_assignable(true)
end)

item:register_event("on_obtaining", function(self)
  game:set_ability("sword", 1)
end)

item:register_event("on_using", function(self)
  local hero = game:get_hero()
  hero:freeze()
  hero:set_animation("charging")
  sol.timer.start(game, 100, function()
    hero:set_sword_sprite_id("hero/spear")
    hero:unfreeze()
    hero:start_attack()
    sol.timer.start(hero:get_map(), 100, function()
      if item:get_variant() >= 2 then item:produce_flame() end
    end)
    local sprite = hero:get_sprite()
    local animation = sprite:get_animation()
    function sprite:on_animation_finished()
      hero:set_sword_sprite_id("hero/sword1")
    end
    item:set_finished()
  end)
end)

function item:produce_flame()
  local hero = game:get_hero()
  local direction = hero:get_direction()
  local dx = {[0] = 36, [1] = 0, [2] = -36, [3] = 0}
  local dy = {[0] = 0, [1] = -36, [2] = 0, [3] = 36}
  local x,y,z = hero:get_position()
  item:get_map():create_fire{
    x = x + dx[direction],
    y = y + dy[direction],
    layer = z,
  }
  dx = {[0] = 24, [1] = 0, [2] = -24, [3] = 0}
  dy = {[0] = 0, [1] = -24, [2] = 0, [3] = 24}
  item:get_map():create_fire{
    x = x + dx[direction],
    y = y + dy[direction],
    layer = z,
  }
  dx = {[0] = 46, [1] = 0, [2] = -46, [3] = 0}
  dy = {[0] = 0, [1] = -46, [2] = 0, [3] = 46}
  item:get_map():create_fire{
    x = x + dx[direction],
    y = y + dy[direction],
    layer = z,
  }
  sol.audio.play_sound"fire_burst_1"
end

--  hero:set_sword_sprite_id("hero/sword2")
--  hero:set_sword_sprite_id("hero/sword1")
