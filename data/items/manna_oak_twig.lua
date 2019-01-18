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