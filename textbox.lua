local utf8 = require('utf8')
local util = require('libs/util')
local lg = love.graphics

-- tb module ---------------------
local tb = {}

tb.meta = {
  __index = tb,
}


function tb.new(x, y, w, h, act_x, act_y, on_enter )
  local new = {

    x = x,
    y = y,
    w = w,
    h = h,

    act_x = act_x,
    act_y = act_y,

    on_enter = on_enter,

    focused = false,

    string = "",
    text = lg.newText(sans, string),
  }
  
  return setmetatable(new, tb.meta)
end


function tb:mousepressed(x, y, b)
  if (b == 1) then
     if (x >= self.act_x and x <= self.act_x + self.w) 
        and
        (y >= self.act_y and y <= self.act_y + self.h) 
        then
        if not self.focused then
          self.string = ""
          self.text:set("") -- set to blank on new focus
          self.focused = true
          if self._onfocus then
            self._onfocus()
          end
        end
        
      else
        self.focused = false
    end
  end
end



function tb:keypressed(key)
  if not self.focused then return end
  if key == 'return' then
    self.on_enter(self)
    return
  elseif key == 'backspace' then
    local byteoffset = utf8.offset(self.string, -1)
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            self.string = string.sub(self.string, 1, byteoffset - 1)
        end
        self.text:set(self.string)
  else
    self.string = self.string .. util.number_filter(key)
    self.text:set(self.string)
  end

  if self._keypressed then
    self._keypressed(self, key)
  end
end


function tb:draw()

  love.graphics.stencil( function() 
                        lg.rectangle('fill', self.x, self.y, self.w, self.h)
                        end,
                        'replace', 1 )

  love.graphics.setStencilTest("greater", 0)


  if self.focused then 
    lg.setColor(color.blue)
  else 
    lg.setColor(color.vlight)
  end

  lg.rectangle('fill', self.x, self.y, self.w, self.h,  ui.roundness)
  lg.setColor(color.white)
  lg.draw(self.text, self.x+5, self.y)
  

  lg.setStencilTest()
end



return tb
