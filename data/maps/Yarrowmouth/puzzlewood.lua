local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "birds")

--footprints
  if game:get_value("puzzlewood_footprints_visible") == true then
    for prints in map:get_entities("footprints") do
      prints:set_enabled(true)
    end
  else
    for prints in map:get_entities("footprints") do
      prints:set_enabled(false)
    end
  end
  

end)