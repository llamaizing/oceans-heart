-- Leaf pile script- modeled after the leaves in Zelda: Oracle of Seasons
-- 
-- Requires the muti-event script for full functionality.
-- which can be found here; 
-- 
-- This script is a custom entity script and provides the functions:
-- custom_entity:keep_existing() which tells the script to respawn the
-- leaves after being destoryed.
-- 
-- custom_entity:get_value() which will return the value of where this
-- entity's destoryed mem state is stored in the save data.

-- Made by Max Mraz, based off the Rock Stack script by yoshimario2000.

 
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = entity:get_game():get_hero()
local name = entity:get_name()
local collapsing = false


-- Event called when the custom entity is initialized.
function entity:on_created()
  entity:set_modified_ground("traversable")

  end


local function destroy_self()
  -- If your sprite has a diffrent animation for being destoryed, change the string "destroy"  into that animation id.
  entity:get_sprite():set_animation("destroy",
  function()
    entity:set_modified_ground("empty")
    entity:set_enabled(false)
  end)
end


map:register_event("on_update", function()
  if map:has_entity(name) then
    if entity:overlaps(hero) and collapsing == false and game:get_value("hero_dashing") == false then
    collapsing = true
    sol.timer.start(200, destroy_self)
    end
  end
end)


