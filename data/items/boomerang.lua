local item = ...
local game = item:get_game()

function item:on_created()

  self:set_savegame_variable("found_boomerang")
  self:set_assignable(true)
end


function item:on_using()

  local hero = self:get_map():get_entity("hero")
  if self:get_variant() == 1 then
    hero:start_boomerang(75, 170, "boomerang1", "entities/boomerang1")
  else
    -- boomerang 2: longer and faster movement
    hero:start_boomerang(150, 250, "boomerang1", "entities/boomerang1")
  end
  self:set_finished()
end
