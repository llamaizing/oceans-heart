local reload_resets = {}

function reload_resets:load_resets(game)
  local hero = game:get_hero()
  hero:set_walking_speed(98)
  
end

return reload_resets