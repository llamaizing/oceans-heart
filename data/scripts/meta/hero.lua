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
    if damage <= 0 then
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


return true