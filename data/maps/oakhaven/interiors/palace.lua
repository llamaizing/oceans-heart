-- Lua script of map oakhaven/interiors/palace.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()


function map:on_started()
  guard_2:set_enabled(false)
  guard_3:set_enabled(false)
  enemy_guard:set_enabled(false)
  if game:get_value("oak_palace_kitchen_fire") == true then guard_1:set_enabled(false) end
  if game:get_value("found_hazel") == true then hazel:set_enabled(false) end
  if game:get_value("mayors_dog_quest_cant_check_litton") == true then
    cant_check_litton_sensor:set_enabled(true)
  end
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") > 5 then
    attic_guard:set_enabled(false)
  end
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") > 6 then
    troll:set_enabled(false)
  end
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 7 and game:get_value("quest_mayors_dog") < 11 then
    happy_mayor:set_enabled(false)
    sad_mayor:set_enabled(true)
    dog:set_enabled(false)
  end
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 11 then
    dog_painting_attic:set_enabled(false)
    attic_painting:set_enabled(false)
    downstairs_dog_painting:set_enabled(true)
  end
end




--MAYOR'S DOG'S BIRTHDAY PARTY QUEST
for npc in map:get_entities("clue_npc") do
  function npc:on_interaction()
    if not game:get_value("quest_mayor_dog_clue_npc"..npc:get_name().."spoken_to") then

      if game:get_value("mayors_dog_clue_npcs_spoken_to") == nil then
        game:start_dialog("_oakhaven.npcs.mayors_party.clues.1", function()
          game:set_value("mayors_dog_clue_npcs_spoken_to", 1)
          game:set_value("quest_mayors_dog", 2)
        end)

      elseif game:get_value("mayors_dog_clue_npcs_spoken_to") == 1 then
        game:start_dialog("_oakhaven.npcs.mayors_party.clues.2", function()
          game:set_value("mayors_dog_clue_npcs_spoken_to", 2)
          game:set_value("quest_mayors_dog", 3)
        end)

      elseif game:get_value("mayors_dog_clue_npcs_spoken_to") == 2 then
        game:start_dialog("_oakhaven.npcs.mayors_party.clues.3", function()
          game:set_value("mayors_dog_clue_npcs_spoken_to", 3)
          game:set_value("quest_mayors_dog", 4)
        end)

      end --end which npc this is
      game:set_value("quest_mayor_dog_clue_npc"..npc:get_name().."spoken_to", true)

    else --if you've already received this clue
      game:start_dialog("_oakhaven.npcs.mayors_party.clues.spoken_to_already")

    end
  end
end


function litton:on_interaction()
  if game:get_value("quest_mayors_dog") < 4 then
    game:start_dialog("_oakhaven.npcs.mayors_party.litton.1")

  elseif game:get_value("quest_mayors_dog") == 4 then
    hero:freeze()
    game:start_dialog("_oakhaven.npcs.mayors_party.litton.2-confrontation", function()
      quirrel_guard:set_enabled(true)
      attic_guard:set_enabled(false)
      local m = sol.movement.create("path")
      m:set_speed(90)
      m:set_path{4,4,4,4,4,4,4,4,4,4,}
      m:start(quirrel_guard, function()
        game:start_dialog("_oakhaven.npcs.mayors_party.litton.3-troll_in_dungeon", function()
          m = sol.movement.create("target")
          m:set_target(tile_target)
          m:set_speed(85)
          m:set_smooth(true)
          hero:set_direction(0)
          hero:set_animation("walking")
          m:start(hero, function()
            game:set_value("quest_mayors_dog", 5)
            litton:set_enabled(false)
            quirrel_guard:set_enabled(false)
            cant_check_litton_sensor:set_enabled(true)
            game:set_value("mayors_dog_quest_cant_check_litton", true)
            troll:set_enabled(true)
            hero:unfreeze()
          end)
        end)
      end)
    end)
  end
end

function cant_check_litton_sensor:on_activated()
  game:start_dialog("_oakhaven.npcs.mayors_party.protect_guests")
  hero:walk("00")
end

function troll:on_dead()
  game:set_value("quest_mayors_dog", 6)
  litton_gone_guard:set_enabled(true)
  cant_check_litton_sensor:set_enabled(false)
  happy_mayor:set_enabled(false)
  sad_mayor:set_enabled(true)
  dog:set_enabled(false)
  game:set_value("mayors_dog_quest_cant_check_litton", false)
end

function litton_gone_guard:on_interaction()
  if game:get_value("quest_mayors_dog") == 6 then
    game:start_dialog("_oakhaven.npcs.mayors_party.guards.litton_gone", function()
      local m = sol.movement.create("path")
      m:set_path{4,4,4,4}
      m:start(litton_gone_guard)
      game:set_value("quest_mayors_dog", 7)
    end)

  elseif game:get_value("quest_mayors_dog") == 7 then

  end
end

function happy_mayor:on_interaction()
  if game:get_value("quest_mayors_dog") <= 6 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayor.1")

  elseif game:get_value("quest_mayors_dog") > 10 then
    if not game:has_item("key_to_oakhaven") then
      game:start_dialog("_oakhaven.npcs.mayors_party.mayor.3", function()
        hero:start_treasure("key_to_oakhaven")
      end)
    else game:start_dialog("_oakhaven.npcs.mayors_party.mayor.4") end
    
  end
end

function dog:on_interaction()
  if game:get_value("quest_mayors_dog") < 10 then
    game:start_dialog("_oakhaven.npcs.mayors_party.dog.1")
  else
    game:start_dialog("_oakhaven.npcs.mayors_party.dog.2")
  end
end

function mayors_friend_1:on_interaction()
  if game:get_value("quest_mayors_dog") < 6 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.1a")
  elseif game:get_value("quest_mayors_dog") < 11 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.1b")
  else
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.1c")
  end
end

function mayors_friend_2:on_interaction()
  if game:get_value("quest_mayors_dog") < 6 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.2a")
  elseif game:get_value("quest_mayors_dog") < 11 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.2b")
  else
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.2c")
  end
end

function mayors_friend_3:on_interaction()
  if game:get_value("quest_mayors_dog") < 6 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.3a")
  elseif game:get_value("quest_mayors_dog") < 11 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.3b")
  else
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.3c")
  end
end






--BREAKING IN, SECRET ARCHIVES QUEST
function first_see_archives_guard_sensor:on_activated()
  if not game:get_value("seen_archives_guard_first_time") then
    game:set_value("seen_archives_guard_first_time", true)
    game:start_dialog("_oakhaven.npcs.guards.palace.archives.1")
  end
end

function sensor_down:on_activated()
  if game:get_value("oak_palace_kitchen_fire") ~= true then
    game:start_dialog("_oakhaven.observations.palace_break_in.too_close_to_guard", function()
      hero:freeze()
      local m = sol.movement.create("path")
      m:set_path{6,6}
      m:start(hero, function() hero:unfreeze() end)
    end)
  end
end

function sensor_right:on_activated()
  if game:get_value("oak_palace_kitchen_fire") ~= true then
    game:start_dialog("_oakhaven.observations.palace_break_in.too_close_to_guard", function()
      hero:freeze()
      local m = sol.movement.create("path")
      m:set_path{0,0}
      m:start(hero, function() hero:unfreeze() end)
    end)
  end
end

function dont_upstairs_sensor:on_activated()
  game:start_dialog("_oakhaven.observations.palace_break_in.dont_upstairs", function()
    hero:walk("66")
  end)
end

function bomb_flower:on_exploded()
  if game:get_value("oak_palace_kitchen_fire") ~= true then
    sol.timer.start(1000, function()
      game:set_value("oak_palace_kitchen_fire", true)
      hero:freeze()
      guard_2:set_enabled(true)
      local gm = sol.movement.create("path")
      gm:set_speed(80)
      gm:set_ignore_obstacles(true)
      gm:set_path{0,0,0,0,0,0,0,0,}
      gm:start(guard_2, function()
      game:start_dialog("_oakhaven.observations.palace_break_in.guard_sees_explosion", function()
        gm:set_path{4,4,4,4,4,4,4,4,4,4,4,4,4,4,}
        gm:start(guard_2, function()
          hero:unfreeze() guard_2:set_enabled(false) guard_1:set_enabled(false)
        end)--end of run left function
      end) --end of dialog function
      end) --end of run right function
    end)
  end --end of conditional branch
end

--find hazel!
function hazel_sensor:on_activated()
  if game:get_value("found_hazel") ~= true then
    game:set_value("found_hazel", true)
    hero:freeze()
    hero:get_sprite():set_animation("walking")
    local mt = sol.movement.create("path")
    mt:set_path{0,0,0,0,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,}
    mt:set_speed(80)
    sol.timer.start(map, 1850, function() hero:get_sprite():set_direction(1) end)
    mt:start(hero, function()
    hero:get_sprite():set_animation("stopped")
    game:start_dialog("_oakhaven.npcs.hazel.palace.1", function()
      guard_3:set_enabled(true)
      local g3 = sol.movement.create("path")
      g3:set_speed(65)
      g3:set_ignore_obstacles(true)
      g3:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0}
      g3:start(guard_3, function()
        game:start_dialog("_oakhaven.npcs.hazel.palace.2", function()
          hero:unfreeze()
          local hm = sol.movement.create("path")
          hm:set_path{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
          hm:set_speed(90)
          hm:start(hazel, function()
            hazel:set_enabled(false)
            game:set_value("quest_hazel", 6) --quest log
          end)
          enemy_guard:set_enabled(true)
          guard_3:set_enabled(false)
          game:set_value("quest_log_a", "a13.5")
        end) --end of guard dialog
      end) --end of guard movement
    end) --end of first dialog function
    end) --end of Tilia movement
  end --end of if you haven't found Hazel branch
end