-- Lua script of map goatshead_island/spruce_head_shrine.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()


map:register_event("on_started", function()
  map:get_camera():letterbox()
  ilex_2:set_enabled(false)
  statue_treasure_chest:set_enabled(false)
  if game:get_value("spruce_head_arborgeist_defeated") == true then
    health_upgrade_door:set_enabled(false)
    spruce_head_arborgeist:set_enabled(false)
  end
  if game:get_value("shsstatue_switch_3") == true then boss_door:set_enabled(false) end


--keep fountains on even if you die
  if game:get_value("shsf1") == true then
    torch_1:set_enabled(true)
    f1_1:set_enabled(true)
    f1_2:set_enabled(true)
    f1_3:set_enabled(true)
  end
  if game:get_value("shsf2") == true then
    torch_2:set_enabled(true)
    f2_1:set_enabled(true)
    f2_2:set_enabled(true)
    f2_3:set_enabled(true)
  end
  if game:get_value("shsf3") == true then
    torch_3:set_enabled(true)
    f3_1:set_enabled(true)
    f3_2:set_enabled(true)
    f3_3:set_enabled(true)
  end
  if game:get_value("shsf4") == true then
    torch_4:set_enabled(true)
    f4_1:set_enabled(true)
    f4_2:set_enabled(true)
    f4_3:set_enabled(true)
  end

--the you haven't initialized this value, do so now
  if game:get_value("spruce_head_shirine_num_fountains_activated") == nil then
    game:set_value("spruce_head_shirine_num_fountains_activated", 0)
  end

end)



--arborgeist battle
function spruce_head_arborgeist:on_dead()
  game:set_value("spruce_head_arborgeist_defeated", true)
  sol.audio.play_sound("door_open")
  sol.audio.play_sound("secret")
  health_upgrade_door:set_enabled(false)
  map:create_pickable({
    layer = 0, x = 1120, y = 136, treasure_name = "health_upgrade",
  })
end

--cyclops battle
function miniboss:on_dead()
  sol.audio.play_sound("door_open")
  miniboss_door:set_enabled(false)
end


--Ilex
function ilex:on_interaction()
  if game:get_value("spruce_head_shrine_central_door") == true then
    game:start_dialog("_goatshead.npcs.ilex.5")
  elseif game:get_value("talked_to_ilex_2") ~= true then
    game:start_dialog("_goatshead.npcs.ilex.3")
    game:set_value("talked_to_ilex_2", true)
    game:set_value("quest_spruce_head", 2) --quest log
  else
    game:start_dialog("_goatshead.npcs.ilex.4")
  end
end

--cutscene
function cutscene_sensor:on_activated()
  if game:get_value("seen_spruce_sanctuary") ~= true then
    ilex_2:set_enabled(true)
    ilex:set_enabled(false)
    local m = sol.movement.create("path")
    m:set_path{2,2,2,2,2,2,2,2,2,2,2,2,2,6}
    m:set_ignore_obstacles(true)
    m:start(ilex_2)
    local t = sol.movement.create("target")
    t:set_target(target_gin)
    t:is_smooth(true)
    t:start(hero)
--    hero:freeze()
      function m:on_finished()
          game:start_dialog("_goatshead.npcs.ilex.6", function()

            game:start_dialog("_goatshead.npcs.ilex.9", function()

              game:set_value("quest_log_a", "a5")
              game:set_value("quest_spruce_head", 3) --quest log
              hero:unfreeze()
              game:set_value("seen_spruce_sanctuary", true)

              game:start_dialog("_game.quest_log_update", function()
                hero:teleport("goatshead/poplar_coast", "from_shrine", "fade")
              end)

            end)

          end)

      end
  end
end
--when ilex is done walking


function ilex_2:on_interaction()
    game:start_dialog("_goatshead.npcs.ilex.8")
end

function gin_bottles:on_interaction()
  game:start_dialog("_goatshead.observations.shrine_bottles")
  game:set_value("checked_spruce_liquer", true)
  game:set_value("spruce_head_shrine_complete", true)
end


--central door
function central_door:on_interaction()
  if game:get_value("shsf1") == true
  and game:get_value("shsf2") == true
  and game:get_value("shsf3") == true
  and game:get_value("shsf3") == true then
    central_door:set_enabled(false)
    sol.audio.play_sound("switch_2")
    game:set_value("spruce_head_shrine_central_door", true)
  else
    game:start_dialog("_game.locked_door")
  end

end

--weak tree falling
function weak_tree_enemy:on_disabled()
  fall_tree_1:set_enabled(true)
  fall_tree_2:set_enabled(true)
  fall_tree_3:set_enabled(true)
end


--fountains
function fountain_switch_1:on_activated()
  if   game:get_value("shsf1") ~= true then
    game:set_value("spruce_head_shirine_num_fountains_activated", game:get_value("spruce_head_shirine_num_fountains_activated") +1 )
    torch_1:set_enabled(true)
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("water_flowing_in_2")end
    f1_1:set_enabled(true)
    f1_2:set_enabled(true)
    f1_3:set_enabled(true)
    game:set_value("shsf1", true)
    fountain_switch_1:set_locked(true)
    if game:get_value("shsf1") == true
    and game:get_value("shsf2") == true
    and game:get_value("shsf3") == true
    and game:get_value("shsf4") == true
    then sol.audio.play_sound("secret") end
end

function fountain_switch_2:on_activated()
  if   game:get_value("shsf2") ~= true then
    game:set_value("spruce_head_shirine_num_fountains_activated", game:get_value("spruce_head_shirine_num_fountains_activated") +1 )
    torch_2:set_enabled(true)
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("water_flowing_in_2")end
    f2_1:set_enabled(true)
    f2_2:set_enabled(true)
    f2_3:set_enabled(true)
    game:set_value("shsf2", true)
    fountain_switch_2:set_locked(true)
    if game:get_value("shsf1") == true
    and game:get_value("shsf2") == true
    and game:get_value("shsf3") == true
    and game:get_value("shsf4") == true
    then sol.audio.play_sound("secret") end
end

function fountain_switch_3:on_activated()
  if   game:get_value("shsf3") ~= true then
    game:set_value("spruce_head_shirine_num_fountains_activated", game:get_value("spruce_head_shirine_num_fountains_activated") +1 )
    torch_3:set_enabled(true)
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("water_flowing_in_2")end
    f3_1:set_enabled(true)
    f3_2:set_enabled(true)
    f3_3:set_enabled(true)
    game:set_value("shsf3", true)
    fountain_switch_3:set_locked(true)
    if game:get_value("shsf1") == true
    and game:get_value("shsf2") == true
    and game:get_value("shsf3") == true
    and game:get_value("shsf4") == true
    then sol.audio.play_sound("secret") end
end

function fountain_switch_4:on_activated()
  if   game:get_value("shsf4") ~= true then
    game:set_value("spruce_head_shirine_num_fountains_activated", game:get_value("spruce_head_shirine_num_fountains_activated") +1 )
    torch_4:set_enabled(true)
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("water_flowing_in_2")end
    f4_1:set_enabled(true)
    f4_2:set_enabled(true)
    f4_3:set_enabled(true)
    game:set_value("shsf4", true)
    fountain_switch_4:set_locked(true)
    if game:get_value("shsf1") == true
    and game:get_value("shsf2") == true
    and game:get_value("shsf3") == true
    and game:get_value("shsf4") == true
    then sol.audio.play_sound("secret") end
end



--secret statue switches
function statue_1:on_interaction()
  sol.audio.play_sound("switch")
  game:set_value("shsstatue_switch_1", true)
end

function statue_2:on_interaction()
  if game:get_value("shsstatue_switch_1") == true then
    sol.audio.play_sound("switch")
    game:set_value("shsstatue_switch_2", true)
  else
    game:set_value("shsstatue_switch_1", false)
    game:set_value("shsstatue_switch_2", false)
  end
end

function statue_3:on_interaction()
  if game:get_value("shsstatue_switch_2") == true then
    sol.audio.play_sound("switch")
    game:set_value("shsstatue_switch_3", true)
    boss_door:set_enabled(false)
    sol.audio.play_sound("secret")
  else
    game:set_value("shsstatue_switch_1", false)
    game:set_value("shsstatue_switch_2", false)
  end
end

--round 1 of secret switches
function statue_4:on_interaction()
  sol.audio.play_sound("switch")
  game:set_value("shsstatue_switch_4", true)
end

function statue_5:on_interaction()
  if game:get_value("shsstatue_switch_4") == true then
    sol.audio.play_sound("switch")
    game:set_value("shsstatue_switch_5", true)
  else
    game:set_value("shsstatue_switch_4", false)
    game:set_value("shsstatue_switch_5", false)
  end
end

function statue_6:on_interaction()
  if game:get_value("shsstatue_switch_5") == true then
    sol.audio.play_sound("switch")
    game:set_value("shsstatue_switch_6", true)
    statue_treasure_chest:set_enabled(true)
    sol.audio.play_sound("secret")
  else
    game:set_value("shsstatue_switch_4", false)
    game:set_value("shsstatue_switch_5", false)
  end
end