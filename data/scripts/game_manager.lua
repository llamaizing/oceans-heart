
require("scripts/multi_events")
require("scripts/weather/weather_manager")
local game_restart = require("scripts/game_restart")
local initial_game = require("scripts/initial_game")
local quest_log = require"scripts/menus/quest_log"
local inventory = require"scripts/menus/inventory"
local quest_update_icon = require"scripts/menus/quest_update_icon"
local objectives_manager = require"scripts/objectives_manager"


local game_manager = {}


--Quest Log Menu: name of sound to play for different new task status keywords
local QUEST_SOUNDS = {
  main_all_completed = false, --TODO need sound
  side_all_completed = false, --TODO need sound
  main_completed = "quest_complete",
  side_completed = "quest_complete",
  main_started = "quest_started",
  side_started = "quest_started",
  main_advanced = "quest_advance",
  side_advanced = "quest_advance",
  new_checkmark = "quest_subtask",
  obtained_quest_item = "quest_subtask",
  main_advanced_again = false, --don't play sound
  side_advanced_again = false, --don't play sound
}

-- Starts the game from the given savegame file,
-- initializing it if necessary.
function game_manager:create(file_name)

    local exists = sol.game.exists(file_name)
    local game = sol.game.load(file_name)
    if not exists then -- Initialize a new savegame.
      initial_game:initialize_new_savegame(game)
    end


  --From llamazing's quest log menu:
    objectives_manager.create(game)
    quest_log:set_game(game)
    	
    function game:on_paused()
      inventory:initialize(game)
    	sol.menu.start(game, inventory)
    end
    	
    function game:on_unpaused()
    	sol.menu.stop(inventory)
    end

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
    	obtained_quest_item = "quest_subtask",
    	main_advanced_again = false, --don't play sound
    	side_advanced_again = false, --don't play sound
    }


    function game.objectives:on_new_task(status, dialog_id)

    	local sound_name = QUEST_SOUNDS[status]
    	if sound_name then sol.audio.play_sound(sound_name) end

      quest_update_icon:refresh_opacity()
      sol.menu.start(game, quest_update_icon)
      sol.timer.start(game, 100, function()
        if quest_update_icon:get_opacity() < 11 then
          sol.menu.stop(quest_update_icon)
        else
          quest_update_icon:reduce_opacity(10)
          return true
        end
      end)

    end


  --end of from llamazings quest log menu


  ---------------------------------------------KEYBOARD INPUTS-----------------------------

  local showing_map
  local ignoring_obstacles
  local can_dash = true

  --display a map when m is pressed
  function game:on_key_pressed(key, modifiers)
    local hero = game:get_hero()
    if key == "m" then
      require("scripts/menus/map")
      if showing_map ~= true then
        sol.audio.play_sound("heart")
        hero:freeze()
        map_screen:get_map(game)
        sol.menu.start(game, map_screen)
        showing_map = true
      else
        sol.menu.stop(map_screen)
        hero:unfreeze()
        showing_map = false
      end

    elseif key == "s" then
    game:start_dialog("_game.pause", function(answer)
      if answer == 1 then
        game:set_paused(false)
      elseif answer == 2 then
        game:save()
        sol.audio.play_sound("elixer_upgrade")
        game:set_paused(false)
      elseif answer == 3 then
        sol.main.exit()
      end
    end)


  --DEBUG FUNCTIONS
  --
      elseif key == "r" then
        if hero:get_walking_speed() == 300 then
          hero:set_walking_speed(debug.normal_walking_speed)
        else
          debug.normal_walking_speed = hero:get_walking_speed()
          hero:set_walking_speed(300)
        end

      elseif key == "t" then
        if not ignoring_obstacles then
          hero:get_movement():set_ignore_obstacles(true)
          ignoring_obstacles = true
        else
          hero:get_movement():set_ignore_obstacles(false)
          ignoring_obstacles = false
        end

      elseif key == "h" then
        game:set_life(game:get_max_life())

      elseif key == "j" then
        game:remove_life(2)
        
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

      if  effect == nil and hero_state == "free"
      and not game:is_suspended() and can_dash then

        local dir = hero:get_direction()
        local dd = {[0]=0,[1]=math.pi/2,[2]=math.pi,[3]=3*math.pi/2} --to convert 0-4 direction to radians
        dir = dd[dir]
        local m = sol.movement.create("straight")
        m:set_angle(dir)
        if game:has_item("dandelion_charm") then
          m:set_speed(325)
          m:set_max_distance(88)
        else
          m:set_speed(200)
          m:set_max_distance(64)
        end
        m:set_smooth(true)
--        hero:freeze()
  --      hero:set_blinking(true, 200)
        if game:has_item("dandelion_charm") then
          hero:get_sprite():set_animation("dash", function() hero:get_sprite():set_animation("walking") end)
          game:set_value("hero_dashing", true)
        else
          hero:get_sprite():set_animation("roll", function() hero:get_sprite():set_animation("walking") end)
          game:set_value("hero_rolling", true)
        end
        if game:has_item("dandelion_charm") then sol.audio.play_sound("dash")
        else sol.audio.play_sound("roll_2") end
        can_dash = false

        m:start(hero, function()
          hero:unfreeze()
          game:set_value("hero_dashing", false)
          game:set_value("hero_rolling", false)
        end)

        sol.timer.start(hero, 1000, function()
          can_dash = true
        end)

        if game:has_item("dandelion_charm") then hero:set_invincible(true, 300) end

        function m:on_obstacle_reached()
          hero:unfreeze()
          sol.timer.start(hero, 800, function()
            can_dash = true
          end)
        end

        hero:register_event("on_position_changed", function()
          if game:get_value("hero_dashing") or game:get_value("hero_rolling") then
            local ground = hero:get_ground_below()
            if ground == "deep_water" or ground == "hole" or ground == "lava" then
              m:stop()
            end
          end
        end)
      end

    end --end of if action == condition
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
          --contine without saving
          elseif answer == 3 then
          --quit
          elseif answer == 4 then
            sol.main.exit()
          end

      --send the hero to the respawn location saved earlier
      game:set_value("gameovering", true)
      game:set_life(game:get_max_life() * .8)
      hero:set_invincible(true, 1500)
      hero:teleport("respawn_map")
      game:stop_game_over()

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
