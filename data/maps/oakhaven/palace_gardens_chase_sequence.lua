local map = ...
local game = map:get_game()

map:register_event("on_started", function()

end)

map:register_event("on_opening_transition_finished", function()
  map:open_doors"secret_tunnel_door"
end)
