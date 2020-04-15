local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  
  for enemy in map:get_entities_by_type"enemy" do
    if enemy:get_breed() == "normal_enemies/arborgeist_stump" then
      enemy:set_life(25+10) enemy:set_hurt_style"normal"
    end
  end

end)
