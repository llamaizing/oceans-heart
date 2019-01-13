game_restart = {}

function game_restart:reset_values(game)
  local hero = game:get_hero()
  game:set_value("hero_dashing", false)
  game:set_value("gameovering", false)
  hero:set_sword_sprite_id("hero/sword1")
end

return game_restart