-- Lua script of map oakhaven/interiors/bomb_shop.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

function bomb_maker:on_interaction()
  --first, finish bomb shop quest:
  if game:get_value("quest_bomb_shop") == nil or game:get_value("quest_bomb_shop") < 4 then
    local quest_value = game:get_value("quest_bomb_shop")

    --start quest
    if quest_value == nil or quest_value == 0 then
      game:start_dialog("_oakhaven.npcs.bomb_shop.owner.1", function()
        game:set_value("quest_bomb_shop", 1)
      end)

    --started quest
    elseif quest_value == 1 or quest_value == 2 then
      game:start_dialog("_oakhaven.npcs.bomb_shop.owner.2")

    --completed quest
    elseif quest_value == 3 then
      game:start_dialog("_oakhaven.npcs.bomb_shop.owner.3", function()
        game:set_value("quest_bomb_shop", 4)
        game:set_value("available_in_shop_bombs", true) --now you can buy bombs everywhere
        for i = 1, 14 do
          sol.timer.start(map, 200 * i, function()
            sol.audio.play_sound("thunk1")
            map:create_pickable{
              x = 172 + (7 * i), y = 148 + math.random(-4, 16), layer = 0,
              treasure_name = "bomb", treasure_variant = 3,
            }
          end)
        end
      end)
    end


  --then, do bomb arrow quest if you have it:
  elseif game:get_value("quest_bomb_arrows") and game:get_value("quest_bomb_arrows") == 0 then
    game:start_dialog("_oakhaven.npcs.shops.bomb_maker.quest1", function()
      game:set_value("quest_bomb_arrows", 1)
      game:set_value("possession_bomb_arrow_ticket", nil)
    end)



  --otherwise, you can just buy bombs
  else
    game:start_dialog("_oakhaven.npcs.shops.bomb_maker.1", function(answer)
      if answer == 2 then
        if game:get_item("firethorn_berries"):get_amount() >= 2 and game:get_money() >= 15 then
          game:remove_money(15)
          game:get_item("firethorn_berries"):remove_amount(2)
          game:get_hero():start_treasure("bomb", 3)
        else
          game:start_dialog("_game.insufficient_items")
        end
      end
    end)
  end

end