local pane = require('pane')
local lg = love.graphics

--play-by-play module--------
-- This really just draws a still image so nbd.
local pbp = {}

local x,y = 214+250, 300
local w, h = lg.getWidth() - x, 200

local pbp_load = function(self)
   self.image = lg.newImage('play_by_play/image.png')
end

local pbp_draw = function(self)

   lg.setColor(color.white)
   local scale = .5
   local x = lg.getCanvas():getWidth()/2 - self.image:getWidth()*scale/2
   local y = lg.getCanvas():getHeight()/2 - self.image:getHeight()*scale/2
   lg.draw(self.image, x, y, 0, scale, scale)
end

local pbp_pane = pane.new(x, y, w, h,
			  pbp_load, nil, pbp_draw,
			  {'bottom', 'right'})


function pbp.update(dt)
end

function pbp.draw()
   pbp_pane:draw()
end



return pbp
