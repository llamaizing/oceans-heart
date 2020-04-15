local map = ...
local game = map:get_game()

map:register_event("on_started", function()

  for blades in map:get_entities("windmill_blades") do
    local sprite = blades:get_sprite()
    sol.timer.start(map, 100, function()
      sprite:set_rotation(sprite:get_rotation() + math.rad(1))
      return true
    end)
  end

end)
