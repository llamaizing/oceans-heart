-- Lua script of map oakhaven/port.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = game:get_hero()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  blackbeard:set_enabled(false)
  morus:set_enabled(false)
  if game:get_value("oakhaven_port_bridge_unblocked") == true then
    bridge_block_door:set_enabled(false)
    bridge_block_door_2:set_enabled(false)
    bridge_block_door_3:set_enabled(false)
    bridge_block_door_4:set_enabled(false)
  end
  if game:get_value("morus_at_port") == true then
    morus_boat_steam:set_enabled(true)
    morus:set_enabled(true)
  end


  if game:get_value("hourglass_fort_read_letter") == true then
    block_guy:set_enabled(false)
    access_block_1:set_enabled(false) access_block_2:set_enabled(false) access_block_3:set_enabled(false)
  end

  if game:get_value("find_burglars") == true then burglar_lookout:set_enabled(false) end

--NPC movement
  local dw1 = sol.movement.create("path")
  dw1:set_path{0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,}
  dw1:set_ignore_obstacles(true)
  dw1:set_loop(true)
  dw1:set_speed(20)
  dw1:start(dockworker_1)

end





function blackbeard_sensor:on_activated()
  if game:get_value("find_burglars") == true and game:get_value("oak_port_blackbeard_cutscene") == nil then
    game:set_value("oak_port_blackbeard_cutscene", true)
    map:get_hero():freeze()
    blackbeard:set_enabled(true)
    local p1 = sol.movement.create("path")
    p1:set_speed(70)
    p1:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,}
    p1:set_ignore_obstacles(true)
    p1:start(blackbeard)

    function p1:on_finished()
      game:start_dialog("_oakhaven.npcs.port.blackbeard.1", function()
        p1:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,}
        p1:start(blackbeard)
        function p1:on_finished()
          blackbeard:set_enabled(false)
          map:get_hero():unfreeze()
        end--end of p1:on_finished
      end)--end of after dialog function
    end--end of p1:on_finished()
  end--end of conditional branch
end




function bridge_switch:on_activated()
  sol.audio.play_sound("switch_2")
  map:open_doors("bridge_block_door")
  game:set_value("oakhaven_port_bridge_unblocked", true)
end


--Ferries
function goatshead_ferry:on_interaction()
  game:start_dialog("_ferries.goatshead", function(answer)
    if answer == 3 then
      if game:get_money() >9 then
        game:remove_money(10)
        hero:teleport("goatshead_island/goatshead_harbor", "ferry_landing")
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end

function yarrowmouth_ferry:on_interaction()
  game:start_dialog("_ferries.yarrowmouth", function(answer)
    if answer == 3 then
      if game:get_money() >9 then
        game:remove_money(10)
        hero:teleport("Yarrowmouth/yarrowmouth_village", "ferry_landing")
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end

function morus:on_interaction()
  if game:has_item("oceansheart_chart") == true then

  else
    game:start_dialog("_oakhaven.npcs.morus.ferry_1", function(answer)
      if answer == 2 then
        hero:teleport("snapmast_reef/landing", "ferry_landing")
      end
    end)
  end
end