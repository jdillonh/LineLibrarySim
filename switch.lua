local switch = {}

local lm = love.mouse

switch.meta = {
  __index = switch,
}

--[[
-- on_t = { color_obj, text }, will be that color, will print that text
-- on_press = function, performed on the switch bing pressed
--]]
function switch.new(x, y, w, h, on_t, off_t, actual_x, actual_y, on_press)
  local new = {
    x = x, --x, y relative to canvas for drawing
    y = y,
    w = w,
    h = h,
    act_x = actual_x,
    act_y = actual_y, --x, y relative to window, for btn press event

    on_press = on_press,

    on = {color = on_t[1], text = on_t[2]},
    off = {color = off_t[1], text = off_t[2]},
    text = lg.newText(sans, off_t[2])
  }
  
  return setmetatable(new, switch.meta)
end


function switch:update()
end

function switch:mousepressed(x, y, b)
  if (b == 1) and
    (x >= self.act_x and x <= self.act_x + self.w) 
    and
    ( y >= self.act_y and y <= self.act_y + self.h) 
    then 
      if not self.pressed then
        self.on_press(self)
        self.pressed = true
        self.text:set(self.on.text)
      else
        self.pressed = false
        self.text:set(self.off.text)
      end
    end
end

function switch:turn_off()
  self.pressed = false
  self.text:set(self.off.text)
end

function switch:draw()
  lg.setColor(color.white)
  if self.pressed then
    lg.setColor(self.on.color)
  else
    lg.setColor(self.off.color)
  end

  lg.rectangle('fill', self.x, self.y, self.w, self.h, ui.roundness)
  lg.setColor(color.white)
  lg.draw(self.text, self.x + (self.w/2) - (self.text:getWidth()/2), self.y + (self.h/2) - (self.text:getHeight()/2))

  lg.setColor(color.white)
end

return switch

