local item = ...
local game = item:get_game()
local map
local hero
local sprite
local NUM_EXPLOSIONS = 4

function item:on_created()
  item:set_savegame_variable("possession_iron_candle")
  item:set_amount_savegame_variable("amount_iron_candle")
  item:set_assignable(true)
end

function item:on_obtaining(variant)
  item:add_amount(10)
end


function item:on_using()
  if item:get_amount() > 0 then
    item:remove_amount(1)
    map = game:get_map()
    hero = game:get_hero()
    sprite = hero:get_sprite()
    hero:freeze()
    sol.audio.play_sound"throw"
    sprite:set_animation("throwing", function()
      hero:unfreeze()
      sprite:set_animation("stopped")
    end)
    local x,y,l = hero:get_position()
    local bomb = map:create_custom_entity({
      direction = 0, x = x, y = y, layer = l, width = 16, height = 16,
      sprite = "entities/iron_candle"
    })
    local m = sol.movement.create("jump")
    m:set_direction8(sprite:get_direction()*2)
    m:set_distance(48)
    m:set_speed(100)
    m:start(bomb)
    sol.timer.start(map, 200, function() bomb:get_sprite():set_animation("sparking") end)
    sol.audio.play_sound"ether_bomb"
    item:explode_bomb(bomb)
    item:set_finished()
  else
    sol.audio.play_sound"no"
    item:set_finished()
  end
end

function item:explode_bomb(bomb)
  local i = 0
  sol.timer.start(map, 2000, function()
    local x,y,l = bomb:get_position()
    sol.audio.play_sound"hand_cannon"
    local explosion = map:create_custom_entity({
      direction=0, x = x, y = y, layer = l, width = 64, height = 64,
      sprite = "entities/explosion_3", model = "damaging_sparkle"
    })
    explosion:get_sprite():set_animation("explosion", function() explosion:remove() end)
    i = i + 1
    if i < 4 then
      sol.audio.play_sound"ether_bomb"
      return true
    else bomb:remove()
    end
  end) --end of timer
 
end