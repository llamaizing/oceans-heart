local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("quest_hazel") == 6 then
    --the chase is on
    for barrel in map:get_entities("blocker_barrel_initial") do
      barrel:set_enabled(false)    
    end
    for pirate in map:get_entities"pirate" do
      pirate:set_enabled()
    end
  end
end)

map:register_event("on_opening_transition_finished", function()
  if not game:get_value("quest_hazel") or game:get_value("quest_hazel") ~= 6 then
    map:open_doors"secret_tunnel_door"
  end
end)
