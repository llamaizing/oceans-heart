-- Lua script of map goatshead_island/interiors/merchant_hq.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local guard_run

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
   self:get_camera():letterbox()
--enable entities
   if game:get_value("mhq_thomas_left") == true then thomas:set_enabled(false) end
   if game:get_value("phantom_squid_quest_completed") ~= true then merchant_hopeful:set_enabled(false) end
   if game:get_value("phantom_squid_quest_completed") ~= true then aster:set_enabled(false) end
   if game:get_value("phantom_squid_quest_completed") == true then eamon:set_enabled(false) end
  
  eamon_winner:set_enabled(false)
  if game:get_value("aster_murdered") == true  and game:get_value("phantom_squid_quest_completed") ~= true then
    eamon:set_enabled(false)
    eamon_winner:set_enabled(true)
  end

--movements
  guard_run = sol.movement.create("path")
  guard_run:set_path{4,4,4,4,4,4,4,4}
  guard_run:set_speed(80)
  guard_run:set_loop(false)
  guard_run:set_ignore_obstacles(true)

end




--talking_to_eamon
function eamon:on_interaction()
--first time talking
  if game:get_value("talked_to_eamon") == nil then
    game:start_dialog("_goatshead.npcs.eamon.1", function(answer)
      if answer == 2 then
        game:start_dialog("_goatshead.npcs.eamon.2", function()
          game:set_value("quest_phantom_squid", 0) --quest log, accept quest
        end)
        game:set_value("talked_to_eamon", 1)
        game:set_value("phantom_squid_quest_accepted", true)
      end
    end)

  --haven't done anything yet
  elseif game:get_value("talked_to_eamon") == 1 then
    game:start_dialog("_goatshead.npcs.eamon.3")

  --accepted Aster's quest
  elseif game:get_value("talked_to_eamon") == 2 then
    game:start_dialog("_goatshead.npcs.eamon.4", function() 
      game:add_money(10)
      game:set_value("talked_to_eamon", 3)
    end)

  elseif game:get_value("talked_to_eamon") == 3 then
    game:start_dialog("_goatshead.npcs.eamon.5")

  end
end

--if you killed Aster
function eamon_winner:on_interaction()
  if game:get_value("taken_eamons_reward") ~= true then
    game:start_dialog("_goatshead.npcs.eamon.killed_astor.1", function()
      game:add_money(60)
      game:set_value("taken_eamons_reward", true)
      game:set_value("quest_phantom_squid", 3)
    end)
  else
    game:start_dialog("_goatshead.npcs.eamon.killed_astor.2")
  end
end

--thomas the guard
function thomas:on_interaction()
  if game:get_value("accepted_merchant_guild_contracts_quest") ~= true then
    game:start_dialog("_goatshead.npcs.guards.thomas.1")
  else
    game:start_dialog("_goatshead.npcs.guards.thomas.2", function()
      game:set_value("possession_aster_note", nil)
      game.objectives:force_update() --TODO quest log issue #70
      guard_run:start(thomas, function() thomas:set_enabled(false) end)
      game:set_value("mhq_thomas_left", true)
    end)
  end
end

--study door
function study_switch:on_activated()
  map:open_doors("eamon_study_door")
end