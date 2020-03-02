
require("scripts/multi_events")
require("scripts/weather/weather_manager")
local game_restart = require("scripts/game_restart")
local initial_game = require("scripts/initial_game")
local pause_menu = require"scripts/menus/pause_menu"
local controls_menu = require"scripts/menus/controls"
--local quest_log = require"scripts/menus/quest_log"
--local pause_inventory = require"scripts/menus/inventory"
local quest_update_icon = require"scripts/menus/quest_update_icon"
local objectives_manager = require"scripts/objectives_manager"
local dash_manager = require"scripts/action/dash_manager"
local map_banner = require"scripts/menus/map_banner"
local world_map = require"scripts/world_map"

local game_manager = {}


--Quest Log Menu: name of sound to play for different new task status keywords
local QUEST_SOUNDS = {
    main_all_completed = "quest_complete",
    side_all_completed = "quest_complete",
    main_completed = "quest_complete",
    side_completed = "quest_complete",
    main_started = "quest_started",
    side_started = "quest_started",
    main_advanced = "quest_advance",
    side_advanced = "quest_advance",
    new_checkmark = "quest_subtask",
    progressed_quest_item = "quest_subtask",
    alternate_swap = "quest_subtask",
    forced_update = "quest_subtask",
    main_advanced_again = false, --don't play sound
    side_advanced_again = false, --don't play sound
}

-- Starts the game from the given savegame file,
-- initializing it if necessary.
function game_manager:create(file_name, overwrite_game)
  if overwrite_game then sol.game.delete(file_name) end
  local exists = sol.game.exists(file_name)
  local game = sol.game.load(file_name)
  if not exists then -- Initialize a new savegame.
    initial_game:initialize_new_savegame(game)
  end

  --set an empty array for holding foraged bushes
  game.foraged_bushes = {}

  --for the location banner on entering locations
  game.map_banner = map_banner

  --allow accessing world_map script from game
  game.world_map = world_map

  objectives_manager.create(game)

  game:register_event("on_started", function()
    game:start_magic_regen_timer()
  end)

  function game:on_paused()
    if not sol.menu.is_started(pause_menu) then sol.menu.start(game, pause_menu) end
  end


  function game.objectives:on_quest_updated(status, dialog_id)
    local sound_name = QUEST_SOUNDS[status]
    if sound_name then sol.audio.play_sound(sound_name) end

    quest_update_icon:refresh_opacity()
    if not sol.menu.is_started(quest_update_icon) then
      sol.menu.start(game, quest_update_icon)
    end
    sol.timer.start(game, 100, function()
      if quest_update_icon:get_opacity() < 11 then
        sol.menu.stop(quest_update_icon)
      else
        quest_update_icon:reduce_opacity(10)
        return true
      end
    end)
  end

  function game:start_magic_regen_timer()
    sol.timer.start(game, 300, function()
      if not game:is_suspended() then
        game:add_magic(1)
      end
      return true
    end)
  end



  ---------------------------------------------KEYBOARD INPUTS-----------------------------

  local showing_map
  local ignoring_obstacles
  local can_dash = true

  local DEBUG_MODE = true                       --HERE IS THE DEBUG MODE SWITCH, MAX!
  pause_menu.quest_log:set_debug_mode(DEBUG_MODE)


  function game:on_key_pressed(key, modifiers)
    local hero = game:get_hero()

    --if function key f2-f5 then open (or close if already open) the corresponding pause submenu directly
    local submenu_index = pause_menu.quick_keys[key]
    if submenu_index then
      pause_menu:toggle_submenu(submenu_index)
      return true
    end

    if key == "f" and sol.menu.is_started(pause_menu) then
      if sol.menu.is_started(pause_menu) then
        pause_menu:next_submenu"left"
      end
    elseif key == "g" and sol.menu.is_started(pause_menu) then
      if sol.menu.is_started(pause_menu) then
        pause_menu:next_submenu"right"
      end

      --DEBUG FUNCTIONS
    -- elseif key == "y" and DEBUG_MODE and game:has_item("sword") then
      -- game:set_ability("sword_knowledge", 1)
      -- hero:start_attack_loading(0)
      -- sol.timer.start(game, 10, function()
      --   game:set_ability("sword_knowledge", 0)
      -- end)

    elseif key == "r"  and DEBUG_MODE then
      if hero:get_walking_speed() == 300 then
        hero:set_walking_speed(debug.normal_walking_speed)
      else
        debug.normal_walking_speed = hero:get_walking_speed()
        hero:set_walking_speed(300)
      end

    elseif key == "t" and DEBUG_MODE then
      if not ignoring_obstacles then
        hero:get_movement():set_ignore_obstacles(true)
        ignoring_obstacles = true
      else
        hero:get_movement():set_ignore_obstacles(false)
        ignoring_obstacles = false
      end

    elseif key == "h" and DEBUG_MODE then
      game:set_life(game:get_max_life())

    elseif key == "j" and DEBUG_MODE then
      game:remove_life(2)

    elseif key == "m" and DEBUG_MODE then
      print("You are on map: " .. game:get_map():get_id())
      local x, y, l = hero:get_position()
      print("at coordinates: " .. x .. ", " .. y .. ", " .. l)

    elseif key == "y" and DEBUG_MODE then
      --helicopter shot
      if not game.helicopter_cam then
        game:get_map():helicopter_cam()
      else
        game:get_map():exit_helicopter_cam()
        require("scripts/action/hole_drop_landing"):play_landing_animation()
      end

         --end of debug functions
          --]]

    end

  end


  ---------------------------------------------command inputs-------------------------------------------------
  function game:on_command_pressed(action)
  --Roll / Dash
  local ignoring_obstacles
  local hero = game:get_hero()
    if action == "action" then
      local effect = game:get_command_effect("action")
      local hero_state = hero:get_state()
      local dx = {[0] = 8, [1] = 0, [2] = -8, [3] = 0}
      local dy = {[0] = 0, [1] = -8, [2] = 0, [3] = 8}
      local direction = hero:get_direction()
      local has_space = not hero:test_obstacles(dx[direction], dy[direction])

      if  effect == nil and hero_state == "free" and hero:get_controlling_stream() == nil
      and not game:is_suspended() and can_dash and has_space then
        dash_manager:dash(game)
        can_dash = false
        sol.timer.start(game, 500, function() can_dash = true end)
      end

    end --end of if action == condition
  end

  function game:on_joypad_button_pressed(btn)
    local handled = false
    if btn == 7 then
      game:simulate_command_pressed"pause"
      handled = true

    elseif btn == 4 then --left bumper
      if sol.menu.is_started(pause_menu) and not sol.menu.is_started(controls_menu) then
        pause_menu:next_submenu"left"
      end
      handled = true
    elseif btn == 5 then --right bumper
      if sol.menu.is_started(pause_menu) and not sol.menu.is_started(controls_menu) then
        pause_menu:next_submenu"right"
      end
      handled = true
    end

    return handled
  end


  --Set Respawn point whenver map changes

  local map_meta = sol.main.get_metatable("map")
  map_meta:register_event("on_opening_transition_finished", function()

    if game:get_value("gameovering") == true then
      game:set_value("gameovering", false)
      local hero = game:get_hero()
      hero:set_position(game:get_value("respawn_x"), game:get_value("respawn_y"), game:get_value("respawn_layer"))
      hero:set_direction(game:get_value("respawn_direction"))
      require("scripts/menus/respawn_screen")
      sol.menu.stop(respawn_screen)

    else

      local map = game:get_map()
      game:set_value("respawn_map", map:get_id() ) --savegame value "respawn map" is this new map's ID
  --    print(map:get_id().." respawn saved")
      local hero = game:get_hero()
      local x, y, layer = hero:get_position()
      game:set_value("respawn_x", x) game:set_value("respawn_y", y) game:set_value("respawn_layer", layer)
      game:set_value("respawn_direction", hero:get_direction())

    end -- end of if gameovering is true

  end)




  ------------------------------------------------------Game Over------------------------------------------------
  local function game_over_stuff_part_2()
      --send the hero to the respawn location saved earlier
      local hero = game:get_hero()
      game:set_value("gameovering", true)
      game:set_life(game:get_max_life() * .8)
      hero:set_invincible(true, 1500)
      hero:teleport("respawn_map")
      game:stop_game_over()
  end

  local function game_over_stuff()
      local elixer = game:get_item("elixer")
      local amount_elixer = elixer:get_amount()
      local hero = game:get_hero()

      if amount_elixer > 0 then
        sol.audio.set_music_volume(game:get_value("music_volume"))
        game:set_life(game:get_value("elixer_restoration_level"))
        hero:set_animation("walking")
        elixer:remove_amount(1)
        game:stop_game_over()
      else
        sol.audio.stop_music()
        sol.audio.set_music_volume(game:get_value("music_volume"))
        game:start_dialog("_game.game_over", function(answer)
          --save and continue
          if answer == 2 then
            game:save()
            game_over_stuff_part_2()
          --contine without saving
          elseif answer == 3 then
            game_over_stuff_part_2()
          --quit
          elseif answer == 4 then
            sol.main.reset()
          end

        end) --end gameover dialog choice
      end --end "if elixers" condition
  end --end gameover stuff function


  function game:on_game_over_started()
    local hero = game:get_hero()
    sol.audio.set_music_volume(1)
    hero:set_animation("dead")
    sol.audio.play_sound("hero_dying")
    sol.timer.start(game, 1500, game_over_stuff)
  end

  --reset some values whenever game starts or restarts
  game:register_event("on_started", function()
    game_restart:reset_values(game)
  end)



  return game
end

return game_manager
