local map = ...
local game = map:get_game()


map:register_event("on_started", function()

end)


function elder:on_interaction()
  if not game:get_value"fykonos_elder_counter" then
    game:start_dialog("_fykonos.npcs.elder.1", function()
      hero:start_treasure("sword_fykonos", 1, nil, function()
        game:set_value("fykonos_elder_counter", 1)
        game:start_dialog"_fykonos.npcs.elder.2"
      end)
    end)

  elseif game:get_value"fykonos_elder_counter" == 1 then
    game:start_dialog"_fykonos.npcs.elder.2"
  end
end

