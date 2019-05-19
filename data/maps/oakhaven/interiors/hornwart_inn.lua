-- Lua script of map oakhaven/interiors/hornwart_inn.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  self:get_camera():letterbox()
  if game:get_value("hornwart_know_hazel") ~= nil then map:open_doors("hazel_door") end
  if game:get_value("quest_manna_oaks") then hazel:set_enabled(false) end
  if game:get_value("found_hazel") ~= true then
    hazel:set_enabled(false)
  else
    for book in map:get_entities("new_book") do book:set_enabled(true) end
  end
  if game:get_value("quest_mangrove_sword") and game:get_value("quest_mangrove_sword") < 4 then
      hazel:set_enabled(false)
  end
end


function beaufort:on_interaction()
  if game:get_value("hornwart_know_hazel") == true then
    game:start_dialog("_oakhaven.npcs.inn.beaufort.3")
  elseif game:get_value("grover_counter") ~= nil and game:get_value("grover_counter") >= 1 then
    game:start_dialog("_oakhaven.npcs.inn.beaufort.2")
    game:set_value("hornwart_know_hazel", true)
  elseif game:get_value("grover_counter") == nil then
    game:start_dialog("_oakhaven.npcs.inn.beaufort.1")
  end

end

for book in map:get_entities("hazel_room_book") do
  function book:on_interaction()
    game:start_dialog(book:get_property("dialog"))
    if game:get_value("hornwart_checkout_books_first_time") ~= true then
      game:set_value("visited_hazel_room", true)
      game:set_value("quest_hazel", 3) --quest log
      game:set_value("hornwart_checkout_books_first_time", true)
    end
  end
end



function hazel:on_interaction()

  --get back from the archives
  if game:get_value("quest_hazel") < 7 then
    game:start_dialog("_oakhaven.npcs.hazel.inn.1", function()
      game:set_value("quest_mangrove_sword", 0) --start sword quest
      game:set_value("quest_hazel", 7) --end hazel quest log
      game:set_value("hazel_is_currently_following_you", true)
      end)

  --finished sword quest
  elseif game:get_value("quest_mangrove_sword") == 4 then
      --manna oaks quest
      if not game:get_value("quest_manna_oaks") then
        game:start_dialog("_oakhaven.npcs.hazel.inn.4gochecktrees")
        game:set_value("quest_manna_oaks", 0)
      elseif game:get_value("quest_manna_oaks") == 0 then
        game:start_dialog("_oakhaven.npcs.hazel.inn.5gogettwigs")
      end
  end
end
