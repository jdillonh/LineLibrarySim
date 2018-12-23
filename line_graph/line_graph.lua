--TODO make bet.current_value depend on graph poisiton



--
local pane = require('pane')
--
local lg = love.graphics


--line_graph module----------------
local line_graph = {}

--constants we need b4 making the actual pane
local graph = {
   x = 214 + 250,
   y = 0,
   w = lg.getWidth() - (214 + 250),
   h = 300, -- TODO change this
   btm_bar_h = 20, 
   game_len = user.game_len, --len of game in sec
   game_done = 0, --% of game done
}

local bars = {}

local bar_scale = 3 --scale delta when drawing bar
local bar_w = 10
local last_bar_x = 22

local new_bar = function(x, delta)
   local c = color.green
   if delta < 0 then c = color.red end
   local x = math.min(math.max(x, 0), graph.w)

   local new = {x = x, color = c, height = delta*bar_scale}
   table.insert(bars, new)
   return new
end


local points = {}
local new_point = function(x, y)
   local y = math.max(y, graph.btm_bar_h)
   local x = math.min(math.max(x, 0), graph.w)
   local new = {x=x, y=y}
   table.insert(points, new)
   return new
end

local last_point = new_point(0,graph.h/2 - 18) --TODO maybe make init price?
local last_point_i = 1
local slope = {x = 1, y = math.random(-10,10)/100}

local graph_load = function(self)
   self.bar_rate = 5 --seconds til new bar
   self.last_bar_t = 0
end



local graph_update = function(self, dt)
   -- graph
   if graph.game_done >= 1 then error("game's done") end
   if math.random(0,500) <= 1 then
      slope.y = math.random(-10,10)/100
   end

   graph.game_done = graph.game_done + (dt/graph.game_len)
   local x = graph.game_done*graph.w + 22
   local y = last_point.y + slope.y
   
   last_point = new_point(x, y)
   last_point_i = last_point_i + 1

   -- bars
   self.last_bar_t = self.last_bar_t + dt
   if self.last_bar_t > self.bar_rate then
      local x =  graph.game_done*graph.w + 22
      local delta = points[#points].y - points[#points-100].y
      new_bar(x - bar_w, delta)
      self.last_bar_t = 0
   end
end


local graph_draw = function(self)
   local side_bar_w = ui.border_width + 15
   local btm_bar_h, btm_bar_w  = ui.border_width + 15, graph.w - 2 * ui.border_width
   local offset = ui.border_width

   -- draw underlay
   lg.setLineWidth(1)
   lg.setColor(color.vlight)
   lg.line(0, graph.h/2 - btm_bar_h, graph.w, graph.h/2 - btm_bar_h) --horiz
   lg.line(graph.w/2 + side_bar_w, 0,  graph.w/2 + side_bar_w, graph.h - 2*offset) --vert

   --draw bars
   for i, bar in pairs(bars) do
      if bar.height < 0 then
	 lg.setColor(color.green)
	 lg.rectangle('fill', bar.x, math.floor(graph.h/2) - 18 , bar_w, bar.height)
	 
      else
	 lg.setColor(color.red)
	 lg.rectangle('fill', bar.x, math.floor(graph.h/2) - 16 , bar_w, math.abs(bar.height))
      end
   end

   --draw graph
   lg.setPointSize(5)
   lg.setColor(color.blue)
   lg.setLineWidth(2)
   lg.setLineStyle('smooth')
   lg.setLineJoin('miter')
   local p = {}
   for i,v in pairs(points) do
      table.insert(p, v.x)
      table.insert(p, v.y)
   end
   lg.line(p)

   --draw bottom bar
   lg.setColor(color.vlight)
   lg.rectangle('fill', offset, graph.h - btm_bar_h   ,  btm_bar_w, 15)
   --draw side bar
   lg.setColor(color.vlight)
   lg.rectangle('fill', 0, offset, side_bar_w, graph.h - 2*offset)
end




line_graph.pane = pane.new(graph.x, graph.y, graph.w, graph.h,
			   graph_load, graph_update, graph_draw,
			   {'bottom', 'right', 'top'})
			   


function line_graph.load()
end


function line_graph.update(dt)
   line_graph.pane:update(dt)
end

function line_graph.draw()
   line_graph.pane:draw()
end

return line_graph 
