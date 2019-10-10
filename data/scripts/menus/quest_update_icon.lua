
local quest_update_icon = {}

local text_surface = sol.text_surface.create({
  font = "oceansfont",
  vertical_alignment = "top",
  horizontal_alignment = "left",
})
local text_key = "menu.quest_update.quest_updated"

function quest_update_icon:on_started()
  --have to wait until after initial menus to get text from strings.dat
  local update_text = sol.language.get_string(text_key)
  assert(update_text, "Strings.dat key not found: "..text_key)
  text_surface:set_text(update_text)
end

function quest_update_icon:on_draw(dst_surface)
  text_surface:draw(dst_surface, 300, 5)
end

function quest_update_icon:get_opacity()
  return text_surface:get_opacity()
end

function quest_update_icon:reduce_opacity(amount)
  text_surface:set_opacity(text_surface:get_opacity() - amount)
end

function quest_update_icon:refresh_opacity()
  text_surface:set_opacity(255)
end

return quest_update_icon