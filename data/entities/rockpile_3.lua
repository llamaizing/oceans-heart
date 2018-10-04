-- Rockstack script ment for rock piles similar to those in alttp.
-- 
-- Requires the muti-event script for full functionality.
-- which can be found here; 
-- 
-- This script is a custom entity script and provides the functions:
-- custom_entity:keep_existing() which tells the script to respawn the
-- rockstack after being destoryed.
-- 
-- custom_entity:get_value() which will return the value of where this
-- entity's destoryed mem state is stored in the save data.
-- 
-- custom_entity:lift_requirement(lvl)
-- lvl - sets the lifting ability that the hero needs
-- inorder to topple the rockstack.
-- 
-- Made by yoshimario2000.
-- Version 1.2
 
-- Local required varables for this script to function properly.
 
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = entity:get_game():get_hero()
local name = entity:get_name()

local being_destroyed

entity:set_layer_independent_collisions(true)


-- Call to get the game var state of this entity.
function get_value()
  local map_id_new = string.gsub(entity:get_map():get_id(), "/", "__")
 
  return map_id_new .. "_" .. entity:get_name() .. "_destroyed"
end
 
-- 
 
local function destroy_self()
  entity:get_sprite():set_animation("destroy", function()
    entity:set_enabled(false)
  end)
end
 
-- Event called when the custom entity is initialized.
function entity:on_created()
  entity:set_modified_ground("wall")
  being_destroyed = false
end
 
-- If you wish to preform the checks another way, please feel free to do so.
-- this was the best way that I could come up with personally though.
map:register_event("on_update", function()
  if map:has_entity(name) then
    if entity:overlaps(hero, "facing") and game:get_value("hero_dashing") == true then
      if being_destroyed == false then destroy_self() end
      being_destroyed = true
    end
  end
end)