local map = ...
local game = map:get_game()
local hero = game:get_hero()

function hazel:on_interaction()
  if not game:has_ability("sword") then
    game:start_dialog("_new_limestone_island.npcs.hazel.1", function()
      hero:start_treasure("sword", 1, "limestone_hazel_gave_you_sword", function()
        game:start_dialog("_new_limestone_island.npcs.hazel.2")
      end)
    end)
  else
    game:start_dialog("_new_limestone_island.npcs.hazel.3")
  end
end