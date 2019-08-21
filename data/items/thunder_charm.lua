local item = ...
local game = item:get_game()

local RANGE = 120
local MAGIC_COST = 40
--The variant will determine the number of lightning bolts called

function item:on_started()
  item:set_savegame_variable("possession_thunder_charm")
  item:set_assignable(true)
end

function item:on_obtained(variant, savegame_variable)
  if variant == 4 then game:set_value("quest_heron_doors", 1) end --quest complete
end

function item:on_using()
  MAGIC_COST = 40 + item:get_variant() * 5
  if game:get_magic() < MAGIC_COST then sol.audio.play_sound("no") item:set_finished()
  else
    game:remove_magic(MAGIC_COST)
    local map = item:get_map()
    local hero = game:get_hero()

    local summoning_state = sol.state.create()
    summoning_state:set_can_control_movement(false)
    summoning_state:set_can_be_hurt(true)
    summoning_state:set_can_use_sword(false)
    summoning_state:set_can_use_item(false)
    summoning_state:set_can_interact(false)
    summoning_state:set_can_grab(false)
    summoning_state:set_can_pick_treasure(false)
    hero:start_state(summoning_state)

    hero:set_animation("charging")
    sol.audio.play_sound("charge_1")
    sol.timer.start(game, 500, function()
      sol.audio.play_sound("thunder3")
      local i = 0
      for entity in map:get_entities() do
        if entity:get_type() == "enemy" and entity:get_distance(hero) <= RANGE then
          i = i + 1
          local x, y, layer = entity:get_position()
          local lightning = map:create_custom_entity{
            name = "lightning_attack",
            direction = 0,
            layer = layer,
            x = x,
            y = y,
            width = 16,
            height = 16,
            sprite = "entities/lightning_bolt_attack",
            model = "damaging_sparkle"
            }
            lightning:set_damage((game:get_value("sword_damage") * 3) or 10)
            sol.timer.start(map, 2000, function() lightning:remove() end)
            if i >= item:get_variant() then
              hero:unfreeze()
              item:set_finished()
              return
            end
          end
      end
      hero:unfreeze()

      local map = game:get_map()
      if map:has_entities("seabird_tear_door") then
        for door in map:get_entities("seabird_tear_door") do
          local x, y, l = door:get_position()
          local lightning = map:create_custom_entity{
          name = "lightning_attack",
          direction = 0,
          layer = l + 1,
          x = x + 8,
          y = y + 8,
          width = 16,
          height = 16,
          sprite = "entities/lightning_bolt_attack",
          model = "damaging_sparkle"
          }
          map:create_poof(x + 8, y + 8, l + 1)
          map:open_doors(door:get_name())
        end
      end

      item:set_finished()

    end) --end of warmup timer callback
  end --end of if has enough magic
end
