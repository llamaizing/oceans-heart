local credits = {}
credits.top = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top"
}
credits.top:set_opacity(0)
credits.bottom = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top"
}
credits.bottom:set_opacity(0)
credits.black = sol.surface.create()
credits.black:fill_color{0,0,0}
credits.black:set_opacity(0)
credits.dialog_text = nil

function credits:on_started()
  local dialog = sol.language.get_dialog("credits") --refresh each time menu starts in case language changed since last time
  assert(dialog, "dialogs.dat entry 'credits' not found")
  self.dialog_text = dialog.text:gsub("\r\n", "\n"):gsub("\r", "\n") --standardize line breaks
  self:roll()
end

function credits:on_finished() self.dialog_text = nil end

function credits:roll()
  self.black:fade_in(150, function()
    sol.timer.start(self, 100, function()
      self.next_text = self.dialog_text:gmatch("([^\n]*)\n") --each line including empty ones
      self:show_next_name()
    end)
  end)
end

function credits:show_next_name()
  local line = self.next_text()
  if line then
    local line1,line2 = line:match("([^%:]*)%:?([^%:]*)") --separate text at colon
    self.top:set_text(line1)
    self.bottom:set_text(line2)
    self.top:fade_in(100)
    self.bottom:fade_in(100, function()
      sol.timer.start(self, 1000, function()
        self.top:fade_out(40)
        self.bottom:fade_out(40, function()
          self:show_next_name()
        end)
      end)
    end)
  else
    sol.timer.start(sol.main, 1000, function()
      sol.menu.stop(self)
      if sol.main:get_game() then
        sol.main.reset()
      else
        sol.menu.start(sol.main, require("scripts/menus/title_screen"))
      end
    end)
  end
end

function credits:on_draw(dst_surface)
  credits.black:draw(dst_surface)
  credits.top:draw(dst_surface, 200, 120)
  credits.bottom:draw(dst_surface, 200, 140)
end

return credits
