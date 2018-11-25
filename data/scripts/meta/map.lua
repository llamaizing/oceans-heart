--Initialize map behavior specific to this quest.

require"scripts/multi_events"

local map_meta = sol.main.get_metatable"map"

function map_meta:set_icon(npc, animation)
	assert(sol.main.get_type(npc)=="npc", "Bad argument #1 to 'set_icon' (sol.main.npc expected)")
	assert(not animation or type(animation)=="string", "Bad argument #2 to 'set_icon' (string expected)")
	
	--create list of icons if it doesn't exist
	self.icons = self.icons or {}
	local icons = self.icons --convenience
	
	if animation then
		local sprite = sol.sprite.create(animation)
		assert(sprite, "Unable to get sprite in 'set_icon': "..animation)
		icons[npc] = sprite
	else icons[npc] = nil end --remove existing icon
end

--// Draw function to handle drawing icons
map_meta:register_event("on_draw", function(self, dst_surface, ...)
	for npc,sprite in pairs(self.icons or {}) do
		local pos_x,pos_y = npc:get_position() --get origin
		if sprite and npc.is_enabled and npc:is_enabled() then
			self:draw_visual(sprite, pos_x, pos_y-24)
		end
	end
end)

local function update_npcs(self)
	local game = self:get_game()
	
	self.icons = {} --reset icons
	
	local is_success = fasle --tentative
	for npc_name in game.objectives:active_npcs() do
		local npc = self:get_entity(npc_name)
		if npc then
			self:set_icon(npc, "entities/exclamation")
			is_success = true
		end
	end
	
	return is_success
end

map_meta.update_icons = update_npcs
map_meta:register_event("on_started", function(self)
	local map = self
	sol.timer.start(map, 1500, function()
		if update_npcs(map) then sol.audio.play_sound"frost1" end
	end)
end)

return true
