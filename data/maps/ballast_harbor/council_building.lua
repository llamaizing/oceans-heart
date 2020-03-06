local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  map:get_camera():letterbox()
end)

function front_door_switch:on_activated()
  map:open_doors("front_door")
end