local map = ...
local game = map:get_game()

function fast_travel:on_interaction()
  local ft_menu = require("scripts/menus/fast_travel")
  sol.menu.start(map, ft_menu)
end
