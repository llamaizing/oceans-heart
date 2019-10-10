--Language selection screen at start of game
--current behavior simply sets language to english

local menu = {}

function menu:on_started()
	if sol.language.get_language() then sol.menu.stop(self) end --language already set, skip this screen
	sol.language.set_language("en")

	--TODO allow player to select language
	sol.menu.stop(self)
end

return menu
