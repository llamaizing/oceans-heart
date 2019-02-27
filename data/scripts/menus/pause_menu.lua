local multi_events = require"scripts/multi_events"

--sub-menus
local quest_log = require"scripts/menus/quest_log"
local inventory = require"scripts/menus/inventory"
local map_screen = require"scripts/menus/map"

local pause_menu = {x=0, y=0}
multi_events:enable(pause_menu)

local game --the current game, must be manually updated using pause_menu:set_game()

local is_changing_menus = false --true while switching between submenus to block keyboard/controller inputs during that time

local SUBMENU_LIST = { --order matters
	inventory,
	quest_log,
    map_screen
} for i,v in ipairs(SUBMENU_LIST) do SUBMENU_LIST[v]=i end --add reverse lookup

local active_submenu --the submenu that is currently being viewed, possible values are string from SUBMENU_LIST ids

local function do_opening_transition()
	local screen_width,screen_height = sol.video.get_quest_size()
	
	--block keyboard/controller inputs during transition
	sol.menu.bring_to_front(pause_menu)
	is_changing_menus = true
	
	--slide menu down from top of screen
	active_submenu:set_xy(0,-1*screen_height)
	local movement = sol.movement.create"straight"
	movement:set_angle(math.pi*3/2) --downward movement
	movement:set_max_distance(screen_height)
	movement:set_speed(500)
	movement:start(active_submenu, function()
		is_changing_menus = false --stop blocking inputs
		sol.menu.bring_to_front(active_submenu) --active submenu processes inputs first
	end)
end

local function do_closing_transition(callback)
	local screen_width,screen_height = sol.video.get_quest_size()
	
	is_changing_menus = true
	
	--slide menu up offscreen
	local movement = sol.movement.create"straight"
	movement:set_angle(math.pi/2) --upward movement
	movement:set_max_distance(screen_height)
	movement:set_speed(500)
	movement:start(active_submenu, function()
		is_changing_menus = false --stop blocking inputs
		if callback then callback() end
	end)
end

--// Call whenever starting new game
function pause_menu:set_game(current_game)
	game = current_game
	
	--set game for sub-menus too
	for _,submenu in ipairs(SUBMENU_LIST) do
		submenu:set_game(current_game)
	end
end

--// Restores position of list from last time viewing menu
function pause_menu:recall_saved_submenu()
	assert(sol.menu.is_started(self), "pause menu must be started before activating a submenu")
	
	local last_index = game:get_value"last_submenu" or 1
	local last_submenu = SUBMENU_LIST[last_index]
	
	self:activate_submenu(last_index)
end

--// Save currently viewed submenu so that it will be the one opened next time
function pause_menu:save_submenu()
	local active_index = SUBMENU_LIST[active_submenu]
	game:set_value("last_submenu", active_index)
end

--// Starts the specified submenu
function pause_menu:activate_submenu(index)
	assert(sol.menu.is_started(self), "pause menu must be started before activating a submenu")
	
	index = tonumber(index)
	assert(index, "Bad argument #2 to 'activate_submenu' (number expected)")
	local submenu = SUBMENU_LIST[index]
	assert(submenu, "Bad argument #2 to 'activate_submenu', invalid index: "..index)
	
	active_submenu = submenu
	sol.menu.start(game, submenu)
end

local DIRECTIONS = { --convert left/right to direction
	left = -1, --previous SUBMENU_LIST entry
	right = 1, --next SUBMENU_LIST entry
}
local ANGLES = { --convert direction to angle
	[-1] = 0, --movement angle to left to access menu on right
	[1] = math.pi --movement angle to right to access menu on left
}
--// Switch active submenu using a scroll transition
	--direction (string, optional) - possible values: "right" or "left", moves to the submenu on the right or left respectively
		--default: "right"
function pause_menu:next_submenu(direction)
	direction = direction or "right" --scroll right by default
	assert(direction, "Bad argument #2 to 'next_submenu' (string or nil expected)")
	local dir_num = DIRECTIONS[direction] --convert left/right to -1/1
	assert(direction, "Bad argument #2 to 'next_submenu', invalid direction: "..direction)
	
	--determine current and next submenus
	local old_submenu = active_submenu
	local old_index = SUBMENU_LIST[active_submenu]
	local new_index = old_index + dir_num
	if new_index < 1 then
		new_index = #SUBMENU_LIST
	elseif new_index > #SUBMENU_LIST then
		new_index = 1
	end
	local new_submenu = SUBMENU_LIST[new_index]
	active_submenu = new_submenu
	
	local screen_width,screen_height = sol.video.get_quest_size()
	
	--open new submenu and move on screen
	sol.menu.start(game, new_submenu)
	sol.menu.bring_to_front(self) --bring pause menu to front temporarily so it can block inputs during transition
	is_changing_menus = true --start blocking keyboard/controller inputs
	new_submenu:set_xy(dir_num*screen_width, 0) --menu should be offscreen before starting movement
	local movement = sol.movement.create"straight"
	movement:set_angle(ANGLES[dir_num])
	movement:set_max_distance(screen_width)
	movement:set_speed(500)
	movement:start(new_submenu, function()
		is_changing_menus = false --stop blocking inputs
		sol.menu.bring_to_front(new_submenu) --now submenu processes inputs first
	end)
	
	--move old submenu off screen and close
	movement = sol.movement.create"straight"
	movement:set_angle(ANGLES[dir_num])
	movement:set_max_distance(screen_width)
	movement:set_speed(500)
	movement:start(old_submenu, function()
		sol.menu.stop(old_submenu)
		old_submenu:set_xy(0,0) --reset its position to center of screen
	end)
end

--// Gets/sets the x,y position of the menu in pixels
function pause_menu:get_xy() return self.x, self.y end
function pause_menu:set_xy(x, y)
	x = tonumber(x)
	assert(x, "Bad argument #2 to 'set_xy' (number expected)")
	y = tonumber(y)
	assert(y, "Bad argument #3 to 'set_xy' (number expected)")
	
	self.x = math.floor(x)
	self.y = math.floor(y)
end

function pause_menu:on_started()
	assert(game, "The current game must be set using 'pause_menu:set_game(game)'")

    --STUFF FROM MAX:
    --a couple submenus need to be initialized before they can be started.
    inventory:initialize(game)
    
	self:recall_saved_submenu()
	do_opening_transition()
end

function pause_menu:on_finished()
	self:save_submenu()
end

function pause_menu:on_command_pressed(command)
	if not is_changing_menus then --must wait for transition to finish before changing submenus again
		if command=="left" or command=="right" then
			self:next_submenu(command)
			
			return true
		end
	end
	
	if command=="pause" then
		do_closing_transition(function()
			sol.menu.stop(active_submenu)
			sol.menu.stop(self)
			game:set_paused(false)
		end)
		return true
	end
end

return pause_menu
