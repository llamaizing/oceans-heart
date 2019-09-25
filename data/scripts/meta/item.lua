-- Initialize equipment item behavior specific to this quest.

require"scripts/multi_events"

--list of consumables
local ITEM_LIST = {
  arrow = true,
  bomb = "bombs_counter.1",
  iron_candle_pickable = true,
  ether_bombs_pickable = true,
  homing_eye_pickable = true,
  berries = "berries.1",
  apples = "apples.1",
  bread = "bread.1",
  elixer = true,
  potion_burlyblade = true,
  potion_fleetseed = true,
  potion_magic_restoration = true,
  potion_stoneskin = true,
  --collectables
  coral_ore = true,
  burdock = true,
  chamomile = true,
  firethorn_berries = true,
  ghost_orchid = true,
  kingscrown = true,
  lavendar = true,
  witch_hazel = true,
  mandrake_white = true,
  mandrake = true,
  geode = "geode.1",
  monster_bones = "monster_bones.1",
  monster_eye = true,
  monster_guts = "monster_guts.1",
  monster_heart = true,
}

local item_meta = sol.main.get_metatable"item"
item_meta:register_event("on_obtained", function(self, variant)
  --trigger quest log update when an item is obtained
  local savegame_variable = self:get_savegame_variable()
  if savegame_variable then
    local game = self:get_game()
    game.objectives:refresh(savegame_variable)
  end

  --display hud panel for consumables when obtained
  local name = self:get_name()
  if ITEM_LIST[name] and self:has_amount() then
    local game = self:get_game()
    local hud = game:get_hud() or {}
    local menu = hud.elements and hud.elements.consumables
    if menu then menu:add_item(self, variant) end
  end
end)


return true
