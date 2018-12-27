-- Lua script of map oakhaven/interiors/melinda.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local chore
-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  chore = false
end

function melinda:on_interaction()
  if chore == true then
    game:start_dialog("_oakhaven.npcs.misc.melinda.0")
  elseif game:get_value("oakhaven_melinda_interactions") == nil then
    game:start_dialog("_oakhaven.npcs.misc.melinda.1", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 2)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 2 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.2", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 3)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 3 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.3", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 4)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 4 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.4", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 5)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 5 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.5", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 6)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 6 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.6", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 7)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 7 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.7", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 8)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 8 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.8", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 9)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 9 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.9", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 10)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 10 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.10", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 11)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 11 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.11", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 12)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 12 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.12", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 13)
    end)
  elseif game:get_value("oakhaven_melinda_interactions") == 13 then
    game:start_dialog("_oakhaven.npcs.misc.melinda.13", function()
      game:add_money(1)
      chore = true
      game:set_value("oakhaven_melinda_interactions", 2)
    end)

  end
end