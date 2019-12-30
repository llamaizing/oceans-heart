-- Initialize hero behavior specific to this quest.

require("scripts/multi_events")

local hero_meta = sol.main.get_metatable("hero")

-- Redefine how to calculate the damage received by the hero.
function hero_meta:on_taking_damage(damage)
  -- In the parameter, the damage unit is 1/2 of a heart.
  local game = self:get_game()
  local defense = game:get_value("defense")
  damage = math.floor(damage*2 / defense)
  if game.take_half_damage then
    damage = damage / 2
  end
  if damage < 1 then
    damage = 1
  end
  --if this attack would kill you in 1 hit at above 40% max life
  if damage >= game:get_life()
  and game:get_life() >= game:get_max_life() * .4
  and damage >= game:get_max_life() * .6
  and not game.guts_save_used then
    --leave you with half a heart
    damage = game:get_life() - 1
    game:get_map():get_camera():shake()
    sol.audio.play_sound"ohko"
    --set this mechanic on a cooldown
    game.guts_save_used = true
    sol.timer.start(game, 40 * 1000, function() game.guts_save_used = false end)
  elseif damage >= game:get_max_life() * .5 then
    sol.audio.play_sound"oh_lotsa_damage"
  end
  game:remove_life(damage)
end


function hero_meta:on_state_changed(state)
  if state == "sword loading" then
    local game = self:get_game()
    if not game:has_item("sword_of_the_sea_king") then
      game:simulate_command_released("attack")
    end
  end
end

function hero_meta:become_all_powerful()
  local game = self:get_game()
  game:set_value("sword_damage", 25)
  game:set_value("bow_damage", 25)
  game:set_value("defense", 25)
  game:set_max_life(52)
  game:set_life(52)
end

local MAX_BUFFER_SIZE = 48
function hero_meta:on_position_changed(x,y,z)
  local hero = self
  if not hero.position_buffer then hero.position_buffer = {} end
  local hero = self
  local dir = hero:get_sprite():get_direction()
  table.insert(hero.position_buffer, 1, {x=x,y=y,layer=l,direction=dir})

  if #hero.position_buffer > MAX_BUFFER_SIZE then
    table.remove(hero.position_buffer)
  end
end

return true