require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_potion_burlyblade")
  item:set_amount_savegame_variable("amount_potion_burlyblade")
  item:set_max_amount(99)
  item:set_assignable(false)
end)

item:register_event("on_obtaining", function(self)
  self:add_amount(1)
end)

item:register_event("on_using", function(self)
  if self:get_amount() > 0 then
    self:remove_amount(1)
    sol.audio.play_sound("uncorking_and_drinking_1")
    game.tilia_damage_multiplier = 1.5
    sol.timer.start(game, 240000, function() --240000 is 4 minutes, 300000 is 5
      game.tilia_damage_multiplier = 1
    end)
  end
  item:set_finished()
end)
