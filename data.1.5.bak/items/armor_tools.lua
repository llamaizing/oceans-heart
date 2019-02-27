local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()
  item:set_savegame_variable("possession_armor_tools")
  -- Initialize the properties of your item here,
  -- like whether it can be saved, whether it has an amount
  -- and whether it can be assigned.
end

function item:on_pickable_created(pickable)

  -- You can set a particular movement here if you don't like the default one.
end
