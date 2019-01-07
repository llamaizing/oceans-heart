-- This script initializes game values for a new savegame file.
-- You should modify the initialize_new_savegame() function below
-- to set values like the initial life and equipment
-- as well as the starting location.
--
-- Usage:
-- local initial_game = require("scripts/initial_game")
-- initial_game:initialize_new_savegame(game)

local initial_game = {}

-- Sets initial values to a new savegame file.
function initial_game:initialize_new_savegame(game)
--Debug Starting Location
                          --DON'T FORGET TO REMOVE ANY DEBUGGING FUNCTIONS FROM GAME_MANAGER, MAX! --

  game:set_starting_location("debug_room", "starting_destination")
--  game:set_starting_location("new_limestone/tavern_upstairs", "destination")

  sol.audio.set_music_volume(60)
  game:set_value("music_volume", 60)

-- hero stats
  game:set_max_life(6)
  game:set_life(game:get_max_life())
  game:set_max_money(9999)
  game:set_money(40)
  game:set_ability("jump_over_water", 1)
  game:set_ability("swim", 0)
  game:set_ability("run", 0)
  game:set_ability("lift", 0)
  game:set_ability("sword", 0)
  game:set_ability("sword_knowledge", 0)
  game:set_value("defense", 2)
  game:set_value("sword_damage", 1)
  game:set_value("bow_damage", 2)
  game:set_value("bomb_damage", 8)
  game:set_value("fire_damage", 2)
  game:set_value("amount_bow", 0)
  game:set_value("elixer_restoration_level", 6) --starts at 6 (3 hearts), then goes to 12, then 18, then 24
  game:set_value("quest_log_a", 0)
  game:set_value("quest_log_b", 0)
  game:set_value("reveal_quest_totals", false)



end

return initial_game