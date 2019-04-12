-- Lua script of map Yarrowmouth/interiors/shop.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local item_lander_x = 200
local item_lander_y = 120

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end


function shopkeeper:on_interaction()
  game:start_dialog("_yarrowmouth.npcs.town_people.shopkeeper_1", function()
    local shop_menu = require("scripts/shops/shop_menu")
    shop_menu:initialize(game)
    sol.menu.start(map, shop_menu)
  end)
end

function buyer_guy:on_interaction()
  game:start_dialog("_generic_dialogs.buyer_guy.1", function()
    local sell_menu = require("scripts/shops/sell_menu")
    sell_menu:initialize(game)
    sol.menu.start(map, sell_menu)
  end)
end