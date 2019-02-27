-- The bow has two variants: without arrows or with arrows.
-- This is necessary to allow it to have different icons in both cases.
-- Therefore, the silver bow is implemented as another item (bow_silver),
-- and calls code from this bow.
-- It could be simpler if it was possible to change the icon of items dynamically.

-- Max addendum: no. Different bow/arrow items are different items. They shoot different arrow entities.
-- The only similarity is that the arrow pickups on the map refil all bow types.


local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_bow_warp")
  item:set_amount_savegame_variable("amount_bow")
  item:set_assignable(true)
end
function item:on_started()
  item:set_max_amount(100)
end


-- set to item slot 1
function item:on_obtained()
--increase bow damage
  game:set_value("bow_damage", game:get_value("bow_damage") + 2)
end


-- Using the bow.

function item:on_using()

  -- item is the normal bow, self can be called by other items.

  local map = game:get_map()
  local hero = map:get_hero()

  if self:get_amount() == 0 then
    sol.audio.play_sound("no")
    self:set_finished()
  else
    hero:set_animation("bow")

    sol.timer.start(map, 290, function()
    sol.audio.play_sound("bow")
      self:remove_amount(1)
      self:set_finished()

       local x, y = hero:get_center_position()
       local _, _, layer = hero:get_position()
       local arrow = map:create_custom_entity({
         x = x,
         y = y,
         layer = layer,
         width = 16,
         height = 16,
         direction = hero:get_direction(),
         model = "arrow_warp",
       })


      arrow:set_force(self:get_force())
      arrow:set_sprite_id(self:get_arrow_sprite_id())
      arrow:go()

    end)
  end
end


function item:get_force()

  return 2
end


-- Set the sprite for the arrow entity

function item:get_arrow_sprite_id()
     return "entities/arrow_warp"

end


