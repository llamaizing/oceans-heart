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
print("TALKING TO BOOK")
    game:start_dialog(book:get_property("dialog"))
    if game:get_value("hornwart_checkout_books_first_time") ~= true then
      game:set_value("visited_hazel_room", true)
      game:set_value("quest_hazel", 3) --quest log
      game:set_value("hornwart_checkout_books_first_time", true)
    end
  end
end



function hazel:on_interaction()

  if game:get_value("hazel_counter") == 1 and game:has_item("tidal_starfruit") == true then
    game:set_value("hazel_counter", 2)
  end


  if game:get_value("hazel_counter") == nil then --first time speaking to hazel at inn
    game:set_value("grover_counter", 2)

    --you have the fruit already for some reason
    if game:has_item("tidal_starfruit") then 
      game:start_dialog("_oakhaven.npcs.hazel.inn.1havefruit", function()
        game:set_value("quest_tidal_starfruit", 3) --quest log, starfruit quest complete
        game:set_value("quest_hazel", 7) --end hazel quest log
        game:set_value("quest_log_a", "a14.5")
        game:set_value("hazel_counter", 2)
      end)
    else

      --normal sequence, didn't get fruit yet
      game:start_dialog("_oakhaven.npcs.hazel.inn.1", function()
        
        game:set_value("quest_hazel", 7) -- quest log, end hazel quest
        game:set_value("quest_tidal_starfruit", 0) --quest log
        game:set_value("quest_log_a", "a14")
        game:set_value("hazel_counter", 1)
      end) --end of dialog callback function
    end


  elseif game:get_value("hazel_counter") == 1 then --go get the starfruit
    game:start_dialog("_oakhaven.npcs.hazel.inn.2")

  elseif game:get_value("hazel_counter") == 2 then --have the starfruit, ready to make amulet
    game:set_value("quest_tidal_starfruit", 3) --quest log, finished starfruit quest
    game:start_dialog("_oakhaven.npcs.hazel.inn.3bringfruit", function()
      game:set_value("morus_available", true)
      game:set_value("grover_counter", 3)
      hero:start_treasure("amulet", 1, "have_amulet", function()
        
        game:set_value("quest_pirate_fort", 0) --quest log, start Morus quest
        game:set_value("quest_log_a", "a15")
        game:set_value("quest_log_b", "b4")
      end) --end of treasure callback function
      game:set_value("hazel_counter", 3)
    end) --end of make the amulet dialog function

  elseif game:get_value("hazel_counter") == 3 then --if Hazel has sent you off to find Morus already
    if game:get_value("quest_manna_oaks") == nil then  --check if you've started Manna Oak quest
      game:start_dialog("_oakhaven.npcs.hazel.inn.4gochecktrees", function()
        game:set_value("quest_manna_oaks", 0)
      end)
    else --you've already started the manna oak quest
      game:start_dialog("_oakhaven.npcs.hazel.inn.5gogettwigs")
    end
  end --end of hazel counter branches
end
