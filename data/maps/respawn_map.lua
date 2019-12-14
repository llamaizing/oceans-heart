local map = ...
local game = map:get_game()
require("scripts/menus/respawn_screen")

function map:on_started()
    sol.menu.start(game, respawn_screen)
    hero:teleport(game:get_value("respawn_map"))

end

function map:on_opening_transition_finished()
--keep this function defined to not set the respawn map as a map to return to after respawning
end
