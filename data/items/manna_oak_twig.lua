local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()
  item:set_savegame_variable("possession_manna_oak_twig")
end


-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)

  -- You can set a particular movement here if you don't like the default one.
end

function item:on_obtained()
  game:set_value("quest_manna_oaks", 1)
  local x, y, layer = game:get_hero():get_position()
  game:get_map():create_enemy({
    x = x, y = y-32, layer = layer, direction = 0, breed = "normal_enemies/pollutant_blob"
  })
end