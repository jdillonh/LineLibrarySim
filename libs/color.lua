local dark = 40

-- color module ---------------------
local color = {

  vlight = {92/255, 101/255, 107/255},
  light = {47/255, 61/255, 69/255}, --light grey
  dark = {21/255, 35/255, 43/255},  --dark grey
  vdark = {20/255 ,28/255 ,33/255}, --TODO background color should be this

  white = {1,1,1},
  black = {0,0,0},

  purple = {0.9, 0.1, 1},
  red = {236/255, 80/255, 41/255},
  dark_red = {(236 - dark)/255, (80 - dark)/255, (41 - dark)/255},
  green = {74/255, 188/255, 50/255},
  dark_green = {(74 - dark)/255, (188 - dark)/255, (50 - dark)/255},
  blue = {53/255, 123/255, 202/255},


}


return color
