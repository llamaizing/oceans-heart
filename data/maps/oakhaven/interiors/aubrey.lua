local map = ...
local game = map:get_game()

function map:on_started()

end

function aubrey:on_interaction()
  --confront aubrey!
  if game:get_value("tic_tac_prize_money_status") == nil then
    aubrey_first_conversation()

  --if you took the money from her
  elseif game:get_value("tic_tac_prize_money_status") == "return" then
    game:start_dialog("_oakhaven.npcs.ana_orange.4")

  --if you let her keep the money
  elseif game:get_value("tic_tac_prize_money_status") == "keep" then
    game:start_dialog("_oakhaven.npcs.ana_orange.5")
  end

end

function aubrey_first_conversation()
  game:start_dialog("_oakhaven.npcs.ana_orange.3", function(answer)
    --hand over the money!
    if answer == 2 then
    game:start_dialog("_oakhaven.npcs.ana_orange.take_money", function()
      game:add_money(200)
      game:set_value("tic_tac_referee_counter", 3)
      game:set_value("quest_tic_tac_toe", 6) --quest log
      game:set_value("tic_tac_prize_money_status", "return")
    end)

    --keep it
    elseif answer == 3 then
    game:start_dialog("_oakhaven.npcs.ana_orange.keep_money", function()
      game:set_value("quest_tic_tac_toe", 8) --quest log
      game:set_value("tic_tac_prize_money_status", "keep")
    end)

    end
  end)
end