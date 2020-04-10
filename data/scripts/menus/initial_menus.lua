--[[initial_menus.lua
	version 1.0
	28 Sep 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ ^ |/ , ,  / ^ | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script manages the initial menus shown when launching the quest. Any active menus
	are closed when a game is started, and the last initial menu should ensure that a game
	is started before it is closed.

	Usage:
	local initial_menus = require"scripts/menus/initial_menu"
	initial_menus.start(context, on_top)
--]]

local multi_events = require"scripts/multi_events"

--menus to show when starting game in this order
--NOTE: the last menu is responsible for starting the game
local MENU_LIST = {
  "scripts/menus/language",
  "scripts/menus/title_screen_menus/top_menu",
}

local initial_menus = {}

local menus = {} --(table, array) list of initial menus
local active_context --(various or nil) context to use for newly started initial menus
local active_menu --(table, key/vale or nil) menu currently active or nil if none
local active_on_top --(boolean or nil) whether newly started initial menus should be drawn on top of other menus

--close any active initial menu when game starts
local game_meta = sol.main.get_metatable"game"
game_meta:register_event("on_started", function(self) initial_menus.stop() end)

--// clear the variables related to the active menu
local function reset()
	active_menu = nil
	active_context = nil
	active_on_top = nil
end

--Initialize
for i,menu_script in ipairs(MENU_LIST) do
	--load initial menu scripts
	local menu = require(menu_script)
	table.insert(menus, menu)

	--register menu with multi-events if not already
	if not menu.register_event then multi_events:enable(menu) end

	--start next menu whenever a menu is closed
	menu:register_event("on_finished", function(self)
		local next_menu = menus[i+1]
		if active_menu and next_menu then --active_menu is nil if a game was started or initial_menus.stop() was called
			active_menu = next_menu

			--if there's an error in starting the next menu then need to set active_menu to nil
			local is_success, err = pcall(function() sol.menu.start(active_context, next_menu, on_top) end)
			if not is_success then
				reset()
				error(err)
			end
		else reset() end --now done
	end)
end

--// Starts the first initial menu, can only be called if no initial menu is currently running
	--context (various, optional) - context to use when starting the menu, see sol.menu.start() documentation
		--default: sol.main
	--on_top (boolean, optional) - whether the menu should be drawn on top of other menus
		--default: false (drawn on bottom)
function initial_menus.start(context, on_top)
	assert(not active_menu, "Error in 'initial_menus': already started")
	if #menus==0 then return end --do nothing if no initial menus defined
	context = context or sol.main
	on_top = on_top or false

	local first_menu = menus[1]
	active_context = context
	active_menu = first_menu
	active_on_top = on_top

	--start the first initial menu, need to set active_menu to nil if there is an error in starting the menu
	local is_success, err = pcall(function() sol.menu.start(context, first_menu, on_top) end)
	if not is_success then
		reset()
		error(err)
	end
end

--// Stops the active initial menu if one is currently active, otherwise does nothing
function initial_menus.stop()
	if active_menu then
		reset() --reset before stopping active menu so next menu won't be started
		sol.menu.stop(active_menu)
	end
end

--// Returns the active initial menu (table, key/value) or nil if not running
function initial_menus.active_menu() return active_menu end

--// Starts the next initial menu if currently running, otherwise does nothing
function initial_menus.next()
	if active_menu then	sol.menu.stop(active_menu) end
end

return initial_menus

--[[ Copyright 2019 Llamazing
  []
  [] This program is free software: you can redistribute it and/or modify it under the
  [] terms of the GNU General Public License as published by the Free Software Foundation,
  [] either version 3 of the License, or (at your option) any later version.
  []
  [] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  [] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  [] PURPOSE.  See the GNU General Public License for more details.
  []
  [] You should have received a copy of the GNU General Public License along with this
  [] program.  If not, see <http://www.gnu.org/licenses/>.
  ]]
