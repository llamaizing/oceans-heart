-- The bow has two variants: without arrows or with arrows.
-- This is necessary to allow it to have different icons in both cases.
-- Therefore, the silver bow is implemented as another item (bow_silver),
-- and calls code from this bow.
-- It could be simpler if it was possible to change the icon of items dynamically.

-- Max addendum: no. Different bow/arrow items are different items. They shoot different arrow entities.
-- The only similarity is that the arrow pickups on the map refil all bow types.


local item = ...
local game = item:get_game()

local MAGIC_COST = 15

function item:on_created()

  item:set_savegame_variable("possession_bow_warp")
  item:set_assignable(true)
end
function item:on_started()
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

  if game:get_magic() < MAGIC_COST then
    sol.audio.play_sound("no")
    self:set_finished()
  else
    game:remove_magic(MAGIC_COST)
    hero:set_animation("bow")

    sol.timer.start(map, 290, function()
    sol.audio.play_sound("bow")
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

      arrow:set_sprite_id("entities/arrow_warp")
      arrow:go()

    end)
  end
end