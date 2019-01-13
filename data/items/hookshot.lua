local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_started()
  item:set_savegame_variable("possession_hookshot")
  item:set_assignable(true)
end

-- Event called when the hero is using this item.
function item:on_using()
  item:get_map():get_hero():start_hookshot()
  item:set_finished()
end

-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)

  -- You can set a particular movement here if you don't like the default one.
end
