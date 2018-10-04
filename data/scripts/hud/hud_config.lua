-- Defines the elements to put in the HUD
-- and their position on the game screen.

-- You can edit this file to add, remove or move some elements of the HUD.

-- Each HUD element script must provide a method new()
-- that creates the element as a menu.
-- See for example scripts/hud/hearts.lua.

-- Negative x or y coordinates mean to measure from the right or bottom
-- of the screen, respectively.

local hud_config = {

  -- Hearts meter.
  {
    menu_script = "scripts/hud/hearts",
    x = 10,
    y = -253,
  },

  -- Rupee counter.
  {
    menu_script = "scripts/hud/rupees",
    -- these coordinates are like, top middle of the screen
    -- x = 121,
    -- y = 10,
    -- but I want bottom right:
    x = 285,
    y = 220,
  },
-- ]]


  -- Bombs counter.
{
    menu_script = "scripts/hud/bombs",
    x = 235,
    y = 220,
  },

  -- Arrows counter.
{
    menu_script = "scripts/hud/arrows",
    x = 260,
    y = 220,
  },


  --[[ Item assigned to slot 1.
  {
    menu_script = "scripts/hud/item",
    x = 20,
    y = 10,
    slot = 1,  -- Item slot (1 or 2).
  },
 


 -- Item assigned to slot 2.
  {
    menu_script = "scripts/hud/item",
    x = 35,
    y = 10,
    slot = 2,  -- Item slot (1 or 2).
  },
--]]

  -- You can add more HUD elements here.
}

return hud_config
