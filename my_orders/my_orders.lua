local pane = require('pane')
local switch = require('switch')
local lg = love.graphics
local color = require('libs/color')

local my_orders = {}
local btn_w, btn_h = 100, 32

local x, y = 214 + 250, 300 + 200
local w, h = lg.getWidth() - (214 + 250), lg.getHeight() - (300 + 200)


local mo_load = function(self)
   local cW = w
   self.ended_switch = switch.new(
      cW - btn_w, 0, btn_w, btn_h,
      {color.blue, 'ended'},
      {color.vdark, 'ended'}, 
      x + cW - btn_w, y 
   )
   self.finished_switch = switch.new(
      cW - 2*btn_w, 0, btn_w, btn_h,
      {color.blue, 'sold'},
      {color.vdark, 'sold'},
      x + cW - 2*btn_w, y 
    )
   self.pending_switch = switch.new(
      cW - 3*btn_w, 0, btn_w, btn_h,
      {color.blue, 'pending'},
      {color.vdark, 'pending'},
      x + cW - 3*btn_w, y 
   )
   self.ended_switch.on_press = function() -- NO self here
      self.finished_switch:turn_off()
      self.pending_switch:turn_off()
   end

   self.finished_switch.on_press = function()
      self.ended_switch:turn_off()
      self.pending_switch:turn_off()
   end

   self.pending_switch.on_press = function()
      self.ended_switch:turn_off()
      self.finished_switch:turn_off()
   end

   self.pending_switch.pressed = true
   self.pending_switch.text:set(
      self.pending_switch.on.text)

end

local mo_update = function(self, dt)
end

local mo_mousepressed = function(self, x, y, b)
   self.pending_switch:mousepressed(x, y, b)
   self.ended_switch:mousepressed(x, y, b)
   self.finished_switch:mousepressed(x, y, b)
end

local mo_draw = function(self)
   self.pending_switch:draw()
   self.ended_switch:draw()
   self.finished_switch:draw()

   local state =
      (self.pending_switch.pressed and 'pending')
      or (self.ended_switch.pressed and 'ended')
      or (self.finished_switch.pressed and 'finished')

   local sepx, sepy = 20, 40
   lg.setColor(color.vlight)
   lg.rectangle("line", sepx, sepy+10, w - 2*sepx, h - 2*sepy)
   lg.stencil(function()
	 lg.rectangle('fill', sepx, sepy + 10, w - 2*sepx, h - 2*sepy)
   end, 'replace', 1)
   lg.setStencilTest('greater', 0)
      
   local barh = h/15
   local n = 1

   local printx, printw = sepx + 5, 60
   --TODO print labels

for i, bet in pairs(user.done_bets) do
      if bet.state == state then
	 local barx, bary = sepx, sepy + 10 + lg.getLineWidth() + n*barh

	 lg.setColor(color.vlight)
	 lg.rectangle('line', barx, bary,
		      w - 2*sepx, h - 2*sepy)
	 lg.setColor(color.white)
	 lg.print(bet.winner.abbrev, printx, bary - 22)
	 lg.print(bet.risk, printx + printw, bary - 22  )
	 lg.print(bet.reward, printx + 2*printw, bary - 22)
	 n = n + 1
      end
   end


   for i, bet in pairs(user.forsale_bets) do
      if bet.state == state then
	 local barx, bary = sepx, sepy + 10 + lg.getLineWidth() + n*barh

	 lg.setColor(color.vlight)
	 lg.rectangle('line', barx, bary,
		      w - 2*sepx, h - 2*sepy)
	 lg.setColor(color.white)
	 lg.print(bet.winner.abbrev, printx, bary - 22)
	 lg.print(bet.risk, printx + printw, bary - 22  )
	 lg.print(bet.reward, printx + 2*printw, bary - 22)
	 lg.print("finding buyer...", printx + 3*printw + 10, bary - 22)
	 n = n + 1
      end
   end

   for i, bet in pairs(user.bets) do
      if bet.state == state then
	 local barx, bary = sepx, sepy + 10 + lg.getLineWidth() + n*barh

	 lg.setColor(color.vlight)
	 lg.rectangle('line', barx, bary,
		      w - 2*sepx, h - 2*sepy)
	 lg.setColor(color.white)
	 lg.print(bet.winner.abbrev, printx, bary - 22)
	 lg.print(bet.risk, printx + printw, bary - 22  )
	 lg.print(bet.reward, printx + 2*printw, bary - 22)
	 n = n + 1
      end
   end

   lg.setStencilTest()
end

	
local mo_pane = pane.new(x, y, w, h,
			 mo_load, mo_update, mo_draw,
			 {'bottom','right'})
mo_pane._mousepressed = mo_mousepressed		 


function my_orders.load()
end

function my_orders.update(dt)

end

function my_orders.mousepressed(x, y, b)
   mo_pane:mousepressed(x, y, b)
end

function my_orders.draw()
   mo_pane:draw()
end


return my_orders

