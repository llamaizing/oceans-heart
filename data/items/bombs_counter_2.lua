require("scripts/multi_events")

local item = ...
local game = item:get_game()

local sound_timer

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_bomb_counter")
  item:set_amount_savegame_variable("amount_bomb_counter")
  item:set_assignable(true)
  item:set_amount_savegame_variable("amount_bomb_counter")
  item:set_max_amount(999)
  bomb_max_amount = self:get_max_amount()
end)

-- set item to slot 2
item:register_event("on_obtaining", function(self)
  game:set_item_assigned(2, self)
  item:set_amount(10)
end)

--THIS IS THE BOMB ITEM WE USE. USES SOL ENGINE'S DEFAULT BOMB


-- Called when the player uses the bombs of his inventory by pressing the corresponding item key.
item:register_event("on_using", function(self)
  if item:get_amount() > 0 then
    item:remove_amount(1)
    local x, y, layer = item:create_bomb()
    sol.audio.play_sound("bomb")
  end
  item:set_finished()
end)

item:register_event("create_bomb", function(self)
  local map = item:get_map()
  local hero = map:get_entity("hero")
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  if direction == 0 then
    x = x + 16
  elseif direction == 1 then
    y = y - 16
  elseif direction == 2 then
    x = x - 16
  elseif direction == 3 then
    y = y + 16
  end
  self:get_map():create_bomb{
    x = x,
    y = y,
    layer = layer
  }
end)
