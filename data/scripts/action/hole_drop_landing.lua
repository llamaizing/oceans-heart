local hole_drop_landing = {}

local fall_maps = {}

local tele_meta = sol.main.get_metatable("teletransporter")

function tele_meta:on_activated()
  local tele = self
  local ground = tele:get_map():get_hero():get_ground_below()
  if ground == "hole" then
    fall_maps[tele:get_destination_map()] = tele:get_destination_name()
  end
end


local dest_meta = sol.main.get_metatable("destination")

function dest_meta:on_activated()
  local dest = self
  if fall_maps[dest:get_map():get_id()] == dest:get_name() then
    hole_drop_landing:play_landing_animation()
  end
end


function hole_drop_landing:play_landing_animation()
  local hero = sol.main.get_game():get_hero()
  hero:freeze()
  sol.audio.play_sound"falling"
  hero:set_visible(false)
  sol.timer.start(sol.main.get_game(), 700, function()
    hero:set_visible(true)
    hero:set_animation("landing", function()
      hero:unfreeze()
      sol.audio.play_sound"hero_lands"
    end)
  end)
end


return hole_drop_landing