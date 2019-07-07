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

local names = {
{"Created By", "Max Mraz"},
{"Additional Programming", "Llamazing"},
{"Special Thanks to", "Alex Gleason"},
{"Thank you for playing",""}
}

function credits:on_started()
  credits:roll()
end

function credits:roll()
  credits.black:fill_color{0,0,0}
  credits.black:fade_in(150, function()
    sol.timer.start(sol.main, 100, function()
      credits:show_name(1)
    end)
  end)
end

function credits:show_name(i)
  credits.top:set_text(names[i][1])
  credits.bottom:set_text(names[i][2])
  credits.top:fade_in(100)
  credits.bottom:fade_in(100, function()
    sol.timer.start(sol.main, 1000, function()
      credits.top:fade_out(40)
      credits.bottom:fade_out(40, function()
        credits:show_next_name(i+1)
      end)
    end)
  end)
end

function credits:show_next_name(i)
  if i <= #names then
    credits:show_name(i)
  else
    sol.timer.start(sol.main, 1000, function()
      sol.menu.stop(require("scripts/menus/credits"))
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