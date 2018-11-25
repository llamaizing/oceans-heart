--[[ quest_log.lua
	version 1.0a1
	23 Nov 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This menu script displays a list of objectives (i.e. quests) that are currently active
	or have previously been completed by the player. The player can traverse the list with
	the up/down keys, and the currently selected objective displays a detailed description
	of subtasks to be completed by the player along with the current status (incomplete or
	complete) and gets updated dynamically as each subtask is finished.
	
	There are two completely different lists of quests that are displayed: main quests and
	side quests. Functionally they behave the same and get displayed on separate tabs that
	the player can switch between using the left/right keys.
]]

local ui = require"scripts/menus/ui/ui"
local util = require"scripts/menus/ui/util"
local quest_data = require"scripts/menus/quest_log.dat"

local quest_log = {}

local game --the current game, must be manually updated using quest_log:set_game()

--tab names and their corresponding index
local LIST_TYPES = {
	"main",
	"side",
} for i,v in ipairs(LIST_TYPES) do LIST_TYPES[v]=i end --add reverse lookup

--additional setter functions to call when creating a new ui component (if a given function exists), order not guaranteed
	--key: property name of the ui component being created
	--value: function to call as method using property value as an argument, i.e. ui_component[value](ui_component, value_of_property(key))
local COMPONENT_FUNCS = {
	is_top_edge = "set_is_top_edge",
	fill = "set_fills",
	subcomponent = "set_subcomponents",
	gap = "set_gap",
	text = "set_text",
	text_key = "set_text_key",
	opacity = "set_opacity",
}

local LIST_VISIBLE_MAX_COUNT

local active_list = {} --list of active objectives
local active_tab_index = 1 --index of active tab: 1="main", 2="side"
local sel_index = 1 --position of highlight box, 1 to 6
local list_index = 1 --selected index of current list
local top_index = 1 --list index appearing at top of visibile objectives in sidebar
local is_highlight = true --if true then highlight box is visible

--// Parses quest_log.dat and creates the corresponding ui components
local load_quest_data --function, only runs once
do
	local is_loaded = false
	load_quest_data = function()
		if not is_loaded then
			assert(type(quest_data)=="table", "Bad data in 'quest_log.dat' (table expected)")
	
			for i,entry in ipairs(quest_data) do
				assert(type(entry.layer)=="string", "Bad property ["..i.."].layer to 'quest_log.dat' (string expected)")
				local component = ui.create_preset(entry.layer, entry.width, entry.height)
		
				--handle special keys in quest_log.dat
				for key,func_name in pairs(COMPONENT_FUNCS) do
					if entry[key]~=nil and type(component[func_name])=="function" then
						component[func_name](component, entry[key])
					end
				end
		
				--save reference to components in quest_data using value of entry_id as key
				local entry_id = entry.id --convenience
				if entry_id then
					assert(type(entry_id)=="string", "Bad property ["..i.."].id to 'quest_log.dat' (string or nil expected)")
					assert(not quest_log[entry_id], "Bad property ["..i.."].id to 'quest_log.dat', duplicate entry: "..entry_id)
			
					quest_log[entry_id] = component
					if not quest_data[entry_id] then quest_data[entry_id] = entry end --add reverse lookup to quest_data
				end
		
				table.insert(quest_log, {component, entry.x, entry.y})
			end
	
			quest_log.menu = ui.new_group(quest_log) --create a new group containing all the menu components
			quest_log.inactive_tab:set_xy(56,0) --move the inactive tab over to become the second tab
	
			quest_log.side_tab_text:set_all("set_enabled", false) --grey text of side tab because it is the inactive tab
			quest_log.tabs_left_arrow:set_visible(false) --hide left arrow because main tab is active
	
			--// populate subcomponents of each list entry group
	
			local group_data = quest_data.list_entry
			assert(type(group_data)=="table", "Bad property list_entry to 'quest_log.dat' (table expected)")
	
			for _,group in quest_log.list_entries:ipairs() do
				local group_list = {} --list of components to be added to this group
				for i,entry in ipairs(group_data) do
					local subcomponent = ui.create_preset(entry.layer, entry.width, entry.height)
			
					--handle special keys in quest_log.dat
					for key,func_name in pairs(COMPONENT_FUNCS) do
						if entry[key]~=nil and type(subcomponent[func_name])=="function" then
							subcomponent[func_name](subcomponent, entry[key])
						end
					end
			
					--setup accessing subcomponent using sub_id key
					local sub_id = entry.sub_id
					assert(type(sub_id)=="string", "Bad property list_entry["..i.."].sub_id to 'quest_log.dat' (string expected)")
					assert(not group[sub_id], "Bad property list_entry["..i.."].sub_id to 'quest_log.dat' (must be unique)")
					group[sub_id] = subcomponent
			
					table.insert(group_list, {subcomponent, entry.x, entry.y})
				end
		
				group:set_subcomponents(group_list)
			end
			
			quest_log.back_prompt:set_text"D Back" --TODO set text dynamically
			
			--// verify remaining data is valid
			
			local tab_offset_x = tonumber(quest_data.tab_offset_x or 0)
			assert(type(tab_offset_x)=="number", "Bad property tab_offset_x to 'quest_log.dat' (number or nil expected)")
			quest_data.tab_offset_x = math.floor(tab_offset_x)
			
			local tab_offset_y = tonumber(quest_data.tab_offset_y or 0)
			assert(type(tab_offset_y)=="number", "Bad property tab_offset_y to 'quest_log.dat' (number or nil expected)")
			quest_data.tab_offset_y = math.floor(tab_offset_y)
			
			local highlight_scroll_time = tonumber(quest_data.highlight_scroll_time or 0.25) --default 250ms
			assert(type(highlight_scroll_time)=="number", "Bad property highlight_scroll_time to 'quest_log.dat' (number or nil expected)")
			assert(highlight_scroll_time>0 and highlight_scroll_time<1, "Bad property highlight_scroll_time to 'quest_log.dat' (number between 0 & 1 or nil expected)")
			quest_data.highlight_scroll_time = highlight_scroll_time
		end
		
		LIST_VISIBLE_MAX_COUNT = quest_log.list_entries:get_count()
		
		is_loaded = true --don't re-create surfaces next time menu is opened
	end
end

--// Call whenever starting new game
function quest_log:set_game(current_game) game = current_game end

--// Restores position of list from last time viewing menu
	--will call quest_log:set_selected()
function quest_log:recall_saved_position(tab)
	local tab_index,tab_name
	
	if tab then --use the tab specified
		local tab_num = tonumber(tab)
		if tab_num then
			tab = LIST_TYPES[tab_num]
			assert(tab, "Bad argument #1 to 'recall_saved_position' (number, string or nil expected)")
		else
			assert(type(tab)=="string", "Bad argument #1 to 'recall_saved_position' (number, string or nil expected)")
		end
		
		tab_name = tab:lower()
		tab_index = LIST_TYPES[tab_name]
		assert(tab_index, "Bad argument #1 to 'recall_saved_position', invalid tab name: "..tab)
	else --use the most recent tab, the value of which is retrieved from savegame data
		tab_name = game:get_value"last_quest_log_tab" or "main"
		assert(type(tab_name), "Bad savegame data: 'last_quest_log_tab' (string expected)") --shouldn't be necessary
		tab_name = string.lower(tab_name)
	
		tab_index = LIST_TYPES[tab_name]
		assert(tab_index, "Bad savegame data: 'last_quest_log_tab' invalid tab name: "..tab_name.." ('main' or 'side' expected)")
		
		self:set_tab(tab_index) --change to specified tab
		
		--active_list = game.objectives:get_objectives_list(tab_name) --list of currently active objectives
	end
	
	local last_master_index = tonumber(game:get_value("last_quest_log_"..tab_name)) --may be nil
	
	--determine value for last_list_index
	local last_list_index = 1 --tentative, use first entry if can't find better one
	if last_master_index then --try to use savegame value
		last_list_index = active_list[tostring(last_master_index)] --objective that was last selected, may be nil if objective is no longer in active list
		
		if not last_list_index then --last viewed objective is no longer in player's quest log
			--choose next lower objective that is on active list instead, or use first entry
			for i,objective in ipairs(active_list) do
				if objective:get_index() < last_master_index then
					last_list_index = i
				else break end
			end
		end
	end
	
	if #active_list > 0 then --player has started at least 1 quest
		local sel_index = 1 --tentative, sets position of highlight box
		local top_index = last_list_index --tentative, index of objective at top of visible list (depends on scroll position)
		
		if #active_list <= LIST_VISIBLE_MAX_COUNT then --not enough entries for list to scroll
			sel_index = last_list_index
			top_index = 1
		elseif last_list_index > #active_list - LIST_VISIBLE_MAX_COUNT + 1 then --if true then highlighted position won't be at top of visible list because is too near bottom of list
			sel_index = LIST_VISIBLE_MAX_COUNT - (#active_list - last_list_index) --highlight position when scrolled all the way to bottom
			top_index = #active_list - LIST_VISIBLE_MAX_COUNT + 1 --index of objective at top of list when scrolled all the way to bottom
		end
		
		self:set_selected(last_list_index, top_index, sel_index)
	else self:set_selected(false) end --display special list when player has no quests in log
end

--// Save currently viewed list entry as savegame variable to recall next time menu is opened
function quest_log:save_position()
	local active_tab_name = LIST_TYPES[active_tab_index]
	local current_objective = active_list[list_index] --may be nil
	local master_index = current_objective and current_objective:get_index() --may be nil
	
	game:set_value("last_quest_log_tab", active_tab_name)
	game:set_value("last_quest_log_"..active_tab_name, master_index) --unsets value if nil (i.e. list is empty)
end

--// Sets which tab is visible in the sidebar
	--index (number) - tab index to make active: 1 = main quests, 2 = side quests
function quest_log:set_tab(index)
	local index = tonumber(index)
	assert(type(index)=="number", "Bad argument #1 to 'set_tab' (number expected)")
	index = math.floor(index)
	assert(index>0, "Bad argument #1 to 'set_tab' (number must be positive)")
	assert(index<=#LIST_TYPES, "Bad argument #1 to 'set_tab' (maximum value: "..#LIST_TYPES)
	
	--configuration of components depends on the index value
	local components = {
		{ --index 1
			left_tab = self.active_tab,
			right_tab = self.inactive_tab,
			visible_arrow = self.tabs_right_arrow,
			invisible_arrow = self.tabs_left_arrow,
			enabled_text = self.main_tab_text,
			disabled_text = self.side_tab_text,
		},
		{ --index 2
			left_tab = self.inactive_tab,
			right_tab = self.active_tab,
			visible_arrow = self.tabs_left_arrow,
			invisible_arrow = self.tabs_right_arrow,
			enabled_text = self.side_tab_text,
			disabled_text = self.main_tab_text,
		},
	}
	
	local c = components[index] --convenience
	c.left_tab:set_xy(0,0)
	c.right_tab:set_xy(quest_data.tab_offset_x, quest_data.tab_offset_y)
	c.visible_arrow:set_visible(true)
	c.invisible_arrow:set_visible(false)
	c.enabled_text:set_all("set_enabled", true)
	c.disabled_text:set_all("set_enabled", false)
	
	self:save_position() --save old tab position
	
	active_tab_index = index --change tabs
	
	local new_tab_name = LIST_TYPES[active_tab_index]
	active_list = game.objectives:get_objectives_list(new_tab_name) --update list of currently active objectives
	
	self:recall_saved_position(new_tab_name) --restores position of list for new tab from last time viewing it, uses specified tab instead of reading last tab from savegame variable
	self:set_top_position()
	
	--set quest completion rate text below sidebar
	local complete_status_text = sol.language.get_string"menu.quest_log.quests_count"
	complete_status_text = util.substitute_text(
		complete_status_text,
		{game.objectives:get_counts(new_tab_name)},
		"%$v"
	)
	self.complete_status:set_text(complete_status_text)
end

function quest_log:set_selected(new_list_index, new_top_index, new_sel_index)
	if not new_list_index then
		self:set_description(false)
		self:set_top_position(false)
		self:set_highlight_position(false)
		return
	end
	
	local new_list_index = tonumber(new_list_index)
	assert(new_list_index, "Bad argument #1 to 'set_selected' (number or nil expected)")
	local new_top_index = tonumber(new_top_index or 1)
	assert(new_top_index, "Bad argument #2 to 'set_selected' (number or nil expected)")
	local new_sel_index = tonumber(new_sel_index or 1)
	assert(new_sel_index, "Bad argument #3 to 'set_selected' (number or nil expected)")
	
	list_index = new_list_index
	self:set_top_position(new_top_index)
	self:set_highlight_position(new_sel_index, false)
	
	self:set_description(list_index) --update description pane
end

--// Moves the selected sidebar list item up or down by the specified amount
--moving below the bottom of the list moves to the first entry
--moving above the top of the list moves to the last entry
	--amount (number, integer) - number of entries to move (positive is down, negative is up)
function quest_log:move_selection(amount)
	if not is_highlight then return end --don't do anything if highlight box not visible
	
	amount = tonumber(amount)
	assert(amount, "Bad argument #1 to 'move_selection' (number expected)")
	amount = math.floor(amount)
	
	local new_index = list_index + amount
	local new_top_index
	
	if amount > 0 then --move down
		if list_index < #active_list then
			list_index = new_index
			
			local bottom_index = top_index + LIST_VISIBLE_MAX_COUNT - 1
			if list_index > bottom_index then --is offscreen below
				bottom_index = list_index
				if #active_list > LIST_VISIBLE_MAX_COUNT then
					new_top_index = bottom_index - LIST_VISIBLE_MAX_COUNT + 1
				end
			end
		else --move to first entry
			list_index = 1
			if #active_list > LIST_VISIBLE_MAX_COUNT then new_top_index = 1 end
		end
	elseif amount < 0 then --move up
		if list_index > 1 then
			list_index = new_index
			
			if list_index < top_index then --is offscreen above
				if #active_list > LIST_VISIBLE_MAX_COUNT then new_top_index = list_index end
			end
		else --move to last entry
			list_index = #active_list
			if #active_list > LIST_VISIBLE_MAX_COUNT then
				new_top_index = list_index - LIST_VISIBLE_MAX_COUNT + 1
			end
		end
	else return end --do nothing for amount of 0
	
	if new_top_index ~= top_index then self:set_top_position(new_top_index) end
	
	local new_sel_index = list_index - top_index + 1
	if sel_index ~= new_sel_index then self:set_highlight_position(new_sel_index) end
	
	self:set_description(list_index)
end

--// Updates description pane per the specified objective object
	--objective (table or number or nil) - specifies which objective to use
		--(table) - objective to use as basis for desc pane content
		--(number) - index of objective from active_list
		--(nil) - Display text that quest log is empty
	--phase (number, index, optional) - manually force the phase to be shown (for debugging)
function quest_log:set_description(objective, phase)
	if objective then
		if type(objective)~="table" then
			assert(type(objective)=="number", "Bad argument #1 to 'set_description' (table or number or nil expected)")
			local index = objective
			objective = active_list[index]
			assert(objective, "Bad argument #1 to 'set_description' (number out of range: "..index)
		end
		
		assert(type(objective)=="table", "Bad argument #1 to 'set_description' (table or number expected)")
		
		local phase = tonumber(phase)
		if phase then phase = math.floor(phase) end
		
		local description = objective:get_description(phase)
	
		self.desc_title:set_text(objective:get_title())
		self.desc_location:set_text(objective:get_location(phase))
		
		--set description pane text and font color depending on if active
		for i,subcomponent in self.desc_text:ipairs() do
			local entry = description[i] or {}
		
			subcomponent:set_text(entry.text or "")
		
			local is_active = entry.is_active==nil and true or entry.is_active --treat nil values as true
			local is_grey = not not entry.is_grey
			--subcomponent:set_enabled(is_active)
			subcomponent:set_enabled(not is_grey)
		end
		
		--set visibility/state of description pane checkmarks
		for i,subcomponent in self.desc_checkmarks:ipairs() do
			local entry = description[i] or {}
			subcomponent:set_visible(entry.is_check or false)
			--subcomponent:set_enabled(entry.is_active==false or false)
			subcomponent:set_enabled(not not entry.is_grey)
		end
		
		--set visibility/state of dynamic checkmarks in description pane
		for i,subcomponent in self.dynamic_checkmarks:ipairs() do
			local entry = description[i] or {}
			subcomponent:set_visible(not not entry.check_state)
			subcomponent:set_enabled(entry.check_state=="checkmark")
			
			if entry.check_position then
				subcomponent:set_xy(6*(entry.check_position-1), 0)
			else subcomponent:set_xy(0,0) end
		end
		
		local is_done = objective:is_done()
		if phase then is_done = phase>=objective:get_num_phases() end
		self.desc_complete:set_visible(is_done)
	else --display blank pane
		self.desc_title:set_text""
		self.desc_location:set_text""
		self.desc_text:set_text_key"menu.quest_log.no_quests"
		self.desc_checkmarks:set_all("set_enabled", false)
		self.desc_complete:set_visible(false)
	end
end

--// Updates quest entry at top of sidebar list to specified index of active_list
	--index (number, integer) - specifies new top position to use
function quest_log:set_top_position(index)
	local index = index or top_index --use current position if index not specified
	index = tonumber(index)
	assert(index, "Bad argument #1 to 'set_top_position' (number or nil expected)")
	index = math.min(math.max(math.floor(index), 1), #active_list)
	
	top_index = index --equal to zero if active_list is empty
	
	--set contents of sidebar list
	for i,group in self.list_entries:ipairs() do
		local objective = active_list[top_index + i - 1] --may be nil
		
		if objective then --populate contents per objective
			group.title:set_text(objective.get_title())
			group.title:set_enabled(not objective:is_done())
			group.location:set_text(objective:get_location())
			group.entry_checkmark:set_visible(objective:is_done())
		else --make blank entry
			group.title:set_text""
			group.title:set_enabled(true)
			group.location:set_text""
			group.entry_checkmark:set_visible(false)
		end
	end
	
	--set visibility of arrows based on current position
	local is_full = #active_list >= LIST_VISIBLE_MAX_COUNT
	self.list_up_arrow:set_visible(is_full and top_index>1)
	local bottom_index = top_index + LIST_VISIBLE_MAX_COUNT - 1
	self.list_down_arrow:set_visible(is_full and bottom_index < #active_list)
end

--// Sets highlight box to the specified index
	--index (number, index, optional) - index of where to set the highlight box, max value is number of visible lines in sidebar list
		--default: set highlight to position 0 and make invisible
	--is_animate (boolean, optional) - if true then highlight box will animate (slide) to specified position (default: true)
function quest_log:set_highlight_position(index, is_animate)
	local is_highlight_visible = not not index
	local index = tonumber(index or 1)
	assert(not is_highlight_visible or index, "Bad argument #1 to 'set_highlight_position' (number or nil expected)")
	index = math.min(math.min(math.max(math.floor(index), 1), LIST_VISIBLE_MAX_COUNT), #active_list) --zero if active_list is empty
	
	assert(not is_animate or type(is_animate)=="boolean", "Bad argument #2 to 'set_highlight' (boolean or nil expected)")
	local is_animate = is_animate~=false
	
	local x,y = self.list_highlight:get_xy()
	
	local x_offset = tonumber(quest_data.list_highlight.x_offset) or 0
	local y_offset = tonumber(quest_data.list_highlight.y_offset) or 0
	
	local new_x = x_offset*(index - 1)
	local new_y = y_offset*(index - 1)
	
	local delta_x = new_x - x
	local delta_y = new_y - y
	local distance = math.sqrt(delta_x*delta_x + delta_y*delta_y)
	local speed = distance/quest_data.highlight_scroll_time
	
	if is_animate then
		local movement = sol.movement.create"target"
		movement:set_speed(speed)
		movement:set_target(new_x, new_y)
		self.list_highlight:start_movement(movement)
	else self.list_highlight:set_xy(new_x, new_y) end
	
	--set visibility of highlight box
	is_highlight = is_highlight_visible
	self.list_highlight:set_visible(is_highlight_visible)
	
	sel_index = index
end

function quest_log:on_started()
	assert(game, "The current game must be set using 'quest_log:set_game(game)'")
	--TODO v1.6 get game using sol.main.get_game() instead
	
	--generate ui components
	load_quest_data() --only loads on first call of function
	
	self:recall_saved_position() --restores position of list from last time viewing it
	self:set_top_position()
	
	game.objectives:clear_new_tasks() --reset when quest log menu is opened
end

function quest_log:on_finished()
	self:save_position()
end

function quest_log:on_command_pressed(command)
	if command=="up" then
		self:move_selection(-1)
		return true
	elseif command=="down" then
		self:move_selection(1)
		return true
	elseif command=="left" then
		if active_tab_index==2 then self:set_tab(1) end
		
		return true
	elseif command=="right" then
		if active_tab_index==1 then self:set_tab(2) end
		
		return true
	elseif command=="attack" then
		--TODO exit menu
		return true
	end
end

local PHASE_KEYS = {} for i=0,9 do PHASE_KEYS[tostring(i)]=true end --keys correspond to numeric keys
local pressed_phase_keys = {} --stores sequence of key presses while shift is held down, to be executed when shift is released

--// Called when the user presses a keyboard key while the menu is active
	--key (string) - name of the raw key that was pressed
	--modifiers (table) - table with keys corresponding to the modifiers that were held down during the key press
		--possible values: "shift", "control", "alt"
		--note: the value of the keys can be ignored
	--returns (boolean) - if true then the event won't be propagated to other objects (e.g. menus or game commands)
function quest_log:on_key_pressed(key, modifiers)
	--manually force the current phase for the displayed description text (for debugging)
	if PHASE_KEYS[key] then --key pressed is 0 to 9
		if not modifiers.shift then
			local current_objective = active_list[list_index]
			self:set_description(current_objective, key) --DEBUG update the description pane to match the phase corresponding to the single pressed key
			print("DEBUG: Displaying description for phase "..key) --DEBUG
			
			pressed_phase_keys = {} --reset for next key press
			
			return true
		else table.insert(pressed_phase_keys, key) end --if shift is held down then capture sequence of key presses
	elseif key=="left shift" or key=="right_shift" then
		pressed_phase_keys = {}
		return true
	end
end

function quest_log:on_key_released(key)
	--when shift is released, concatenate the list of key presses while it had been held down, convert to number and execute
	if (key=="left shift" or key=="right shift") and #pressed_phase_keys>0 then
		local pressed_num = tonumber(table.concat(pressed_phase_keys, ""))
		if pressed_num then --if sequence of key presses is a valid number
			local current_objective = active_list[list_index]
			self:set_description(current_objective, pressed_num) --DEBUG update the description pane to match the phase corresponding to the pressed key sequence
			print("DEBUG: Displaying description for phase "..pressed_num) --DEBUG
		end
		
		pressed_phase_keys = {} --reset for next key press
		
		return true
	end
end

function quest_log:on_draw(dst_surface)
	self.menu:draw(dst_surface)
end

return quest_log

--[[ Copyright 2018 Llamazing
  [[ 
  [[ This program is free software: you can redistribute it and/or modify it under the
  [[ terms of the GNU General Public License as published by the Free Software Foundation,
  [[ either version 3 of the License, or (at your option) any later version.
  [[ 
  [[ It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  [[ without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  [[ PURPOSE.  See the GNU General Public License for more details.
  [[ 
  [[ You should have received a copy of the GNU General Public License along with this
  [[ program.  If not, see <http://www.gnu.org/licenses/>.
  ]]