-- Initialize hero behavior specific to this quest.

require("scripts/multi_events")

local hero_meta = sol.main.get_metatable("hero")

-- Redefine how to calculate the damage received by the hero.
function hero_meta:on_taking_damage(damage)
--TODO: make it so explosion damage ignores defense
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

return true