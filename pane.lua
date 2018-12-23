local color = require('libs/color')
local util  = require('libs/util')

--
local lg = love.graphics
local lm = love.mouse
--

-- pane module -----------------------------------------
local pane = {}


pane.meta = {
  __index = pane,
}



--[[
-- position = { 'top', 'bottom', 'left', 'right' }, including a side means a border will be placed there
--
-- draw, function that takes self
-- update, function that takes self
-- pane.new calls the load function before returning the new object!
--]]
function pane.new(x, y, w, h, load, update, draw, position)
   assert(w, "no w")
  local new = {
    x = x,
    y = y,
    w = w,
    h = h,
    _load = load,
    _draw = draw,  --NOTE these are '_draw' and '_update' to prevent namespace issues with setmetatable and pane module
    _update = update, 
  }

  new.canvas = lg.newCanvas(w, h)

  local top =   util.contains(position,'top')
  local btm =   util.contains(position,'bottom')
  local left =  util.contains(position,'left')
  local right = util.contains(position,'right')

  new.back = {  --background rectangle draw
    x = 0,
    y = 0,
    w = w,
    h = h,
  }

  if left then 
    new.back.x = new.back.x + ui.border_width 
    new.back.w = new.back.w - ui.border_width
  end

  if top then 
    new.back.y = new.back.y + ui.border_width 
    new.back.h = new.back.h - ui.border_width
  end

  if right then
    new.back.w = new.back.w - ui.border_width
  end

  if btm then
    new.back.h = new.back.h - ui.border_width
  end

  setmetatable(new, pane.meta)
  if new._load then
    new._load(new)
  end

  return new
end


function pane:update(dt)
  if self._update then
    self._update(self, dt)
  end
end


-- Note self._mousepressed is a secret function, must be set explicitly... mypane._mousepressed = function(x,y,b) ... end 
function pane:mousepressed(x, y, button)
  if self._mousepressed then
    self._mousepressed(self, x, y, button)
  end
end

-- another secret function i gues... I just don't wnat to add it to the constructer oh well
function pane:keypressed(key)
  if self._keypressed then
    self._keypressed(self, key)
  end
end


function pane:draw()
  assert(self.canvas ~= nil)
  lg.setCanvas({self.canvas, stencil = true})
  lg.setColor(color.white)
  lg.setColor(ui.fg_color)
  --lg.rectangle("fill",0,0,10,10)

  lg.rectangle('fill', self.back.x, self.back.y, self.back.w, self.back.h, ui.roundness)
  if self._draw then
    self._draw(self)
  end
  

  lg.setCanvas()
  lg.setColor(1,1,1)
  lg.draw(self.canvas, self.x, self.y)
end





return pane

