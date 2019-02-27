-- Rockstack for rock stacks like ALTTP, adapted for this game's dash ability
--Based on a script by Yoshimario 2000
  
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = entity:get_game():get_hero()
local being_destroyed
local name = entity:get_name()

local function destroy_self()
  sol.audio.play_sound("running_obstacle")
  entity:get_sprite():set_animation("destroy", function()
    entity:set_enabled(false)
  end)
end
 

function entity:on_created()
  entity:set_modified_ground("wall")
  being_destroyed = false
end

 
--Checking to see if the hero is ramming into the pile of rocks
map:register_event("on_update", function()
  if map:has_entity(name) then
    if entity:overlaps(hero, "facing")
    and (game:get_value("hero_dashing") == true or hero:get_state() == "running") then
      if being_destroyed == false then destroy_self() end
      being_destroyed = true
    end
  end
end)