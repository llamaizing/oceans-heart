local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 11 then
    litton:set_enabled(true)
  end

  if game:get_value("quest_oakhaven_musicians") and game:get_value("quest_oakhaven_musicians") >= 3 then
    trumpet_player:set_enabled(true)
  end

  if game:get_value("quest_briarwood_mushrooms") and game:get_value("quest_briarwood_mushrooms") >= 3 then
    michael:set_enabled(true)
  end

  if game:get_value("quest_pirate_fort") and game:get_value("quest_pirate_fort") >= 6 then
    jazari:set_enabled(true)
  end
