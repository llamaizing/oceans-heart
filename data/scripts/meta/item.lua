-- Initialize equipment item behavior specific to this quest.

require"scripts/multi_events"

--list of consumables
local ITEM_LIST = {
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
	geode = true,
	monster_bones = true,
	monster_eye = true,
	monster_guts = true,
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
  print(name, variant)
  if ITEM_LIST[name] and self:has_amount() then
    local game = self:get_game()
    local hud = game:get_hud() or {}
    local menu = hud.elements and hud.elements.consumables
    if menu then menu:add_item(self, variant) end
  end
end)


return true
