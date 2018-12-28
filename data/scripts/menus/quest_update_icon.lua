
local quest_update_icon = {}

local text_surface = sol.text_surface.create({
  font = "oceansfont",
  vertical_alignment = "top",
  horizontal_alignment = "left",
})

text_surface:set_text("Quest Log Updated!")


function quest_update_icon:on_draw(dst_surface)
  text_surface:draw(dst_surface, 200, 10)
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