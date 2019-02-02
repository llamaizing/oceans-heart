-- SINKING PALACE LIGHTHOUSE

local map = ...
local game = map:get_game()

function map:on_started()
  if game:get_value("sinking_palace_lighthouse_lit") then
    for fire in map:get_entities("lighthouse_flame") do
      fire:set_enabled(true)
    end
  end
end

function map:on_opening_transition_finished()

end

function lighthouse_switch:on_activated()
  if not game:get_value("sinking_palace_lighthouse_lit") then
    for fire in map:get_entities("lighthouse_flame") do
      fire:set_enabled(true)
    end
    sol.audio.play_sound("switch")
    sol.audio.play_sound("secret")
    game:set_value("sinking_palace_lighthouse_lit", true)
    game:start_dialog("_goatshead.observations.lighthouse_lit")
    game:set_value("lighthouses_quest_num_lit", game:get_value("lighthouses_quest_num_lit") + 1)
    if game:get_value("lighthouses_quest_num_lit") >= 4 then
      game:set_value("quest_lighthouses", 1)
    end
  end
end