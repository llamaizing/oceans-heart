local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_potion_stoneskin")
  item:set_amount_savegame_variable("amount_potion_stoneskin")
  item:set_max_amount(99)
  item:set_assignable(false)
end

function item:on_obtained()
  self:add_amount(1)
end


function item:on_using()
  game.take_half_damage = true
  sol.timer.start(game, 240000, function() --240000 is 4 minutes, 300000 is 5
    game.take_half_damage = false
  end)
  item:set_finished()
end