
-- TODO add 'spread picker'

local tb = require('textbox')
local pane =   require('pane')
local button = require('button')
local switch = require('switch')
local util = require('libs/util')
local bet = require('bet')
--
local lg = love.graphics
local lk = love.keyboard
--


--order module---------------------
local order = {}




order.state = 'buy' -- 'buy' or 'sell'
order.teams = {'NU', 'UM'}

-- BALANCE PANE ----------------------------
order.balance_pane = {
  x = 0,
  y = 0,
  w = 214,
  h = 200,
  balance = 100,
}
local bp = order.balance_pane -- local alias

local bp_load = function(self)
  self.bal_label = lg.newText(sans, "Balance:") 
  self.bal_num = lg.newText(sans, '$' .. tostring(user.balance)) 

  self.dep_btn = button.new( self.w/6, self.w/2 --[[3/6]], self.w/3, self.h/9,
                              {color.green, "+ DEP" }, {color.dark_green, "+ DEP"},
                              bp.x + self.w/6, bp.y + self.w/2,
                              function() user.balance = user.balance + 100 end)

  self.wit_btn = button.new( self.w/2, self.w/2, self.w/3, self.h/9,
                              {color.red, "- WIT" }, {color.dark_red, "- WIT"},
                              bp.x + self.w/2, bp.y + self.w/2,
                              function() user.balance = user.balance - 100 end)
end

local bp_update = function(self)
  self.bal_num:set('$' .. tostring(user.balance))
  self.dep_btn:update()
  self.wit_btn:update()
end

local bp_draw = function(self) 
  local bal_label = self.bal_label
  lg.setColor(color.white)
  --Draw Balance Label
  lg.draw(bal_label, math.floor((self.w / 2) - (bal_label:getWidth() / 2)), 
                     math.floor((self.h / 6) -  bal_label:getHeight()))

  --Draw the Balance Number
  local bal_num = self.bal_num
  lg.draw(bal_num, math.floor( (self.w / 2) - (bal_num:getWidth() / 2)), math.floor((self.h / 3) - bal_num:getHeight()))

  --Draw the + / - buttons
  self.dep_btn:draw()
  self.wit_btn:draw()

end

bp.pane = pane.new(0, 0, 214, 200, bp_load, bp_update, bp_draw, {'top','bottom','left','right'})



-- BUY PANE ----------------------------------------------------------------------------------------------------------
--lower pane, with Buy Sell menu

--TODO this can be moved to bsp_load???
order.buy_sell_pane = {
  x = 0,
  y = bp.y + bp.h,
  w = bp.w,
  h = love.graphics.getHeight() - bp.h,
  state = 'buy' -- or 'sell'
}

local bsp = order.buy_sell_pane

local bsp_load = function(self)
  self.label = lg.newText(sans, "Order Form")
  self.buy_switch = switch.new(self.w/2, self.h/5, self.w/3, self.h/20,
                                    {color.green, "BUY"}, {color.dark, "BUY"}, --TODO make this team1 and team2
                                    bsp.x + self.w/2, bsp.y + self.h/5,
                                    function(self) order.buy_sell_pane.pane.sell_switch.pressed = false  end)
  self.buy_switch.pressed = true
  local b_s = self.buy_switch
  self.sell_switch = switch.new(self.w/2 - b_s.w , self.h/5, self.w/3, self.h/20,
                                     {color.dark_red, "SELL"}, {color.dark, "SELL"}, --TODO make this team1 and team2
                                     bsp.x + self.w/2 - b_s.w, bsp.y + self.h/5,
                                     function(self) order.buy_sell_pane.pane.buy_switch.pressed = false end)

                                     

  --- BUY state things ---
  local team_y = 3 * self.h / 10
  self.team1_switch = switch.new(self.w/2         , team_y , self.w/3, self.h/20,
                                     {color.purple, team1.abbrev }, {color.dark, team1.abbrev}, -- TODO make this team1 and team2
                                     bsp.x + self.w/2, bsp.y + team_y,
                                     function(self) 
                                       order.buy_sell_pane.pane.team2_switch.pressed = false 
                                       team1.selected = true
                                       team2.selected = false
                                     end)
  local t_1 = self.team1_switch
  
  self.team2_switch = switch.new(self.w/2 - t_1.w , team_y , self.w/3, self.h/20,
                                     {color.dark_red, team2.abbrev}, {color.dark, team2.abbrev}, -- TODO make this team1 and team2
                                     bsp.x + self.w/2 - t_1.w, bsp.y + team_y,
                                     function(self) 
                                       order.buy_sell_pane.pane.team1_switch.pressed = false 
                                       team2.selected = true
                                       team1.selected = false
                                     end)

  -- label added, usig lg.print
  self.price_tb =       tb.new(self.w/2 - t_1.w, 4 * self.h /10, 2 * self.w/3, self.h/20,
                                 bsp.x + self.w/2 - t_1.w, bsp.y +(4 * self.h/10),
                                 function(self)   end)
  
  self.reward_tb =       tb.new(self.w/2 - t_1.w, 5 * self.h /10, 2 * self.w/3, self.h/20,
                                 bsp.x + self.w/2 - t_1.w, bsp.y +(5 * self.h/10),
                                 function(self)   end)
  -- RISK / REWARD textboxes
  self.price_tb._keypressed = 
    function(self, key)  
      if not ((util.number_filter(key) ~= "") or (key == "backspace")) then 
        return
      end
      local reward = order.buy_sell_pane.pane.reward_tb
      if self.string == "" then
        reward.string = ""
      else
        reward.string = tostring(tonumber(self.string) * 0.909)
      end
      reward.text:set(reward.string)
      
      --set the user vars
      user.reward =  tonumber(reward.string)
      user.risk =  tonumber(self.string)
    end

  self.price_tb._onfocus = 
    function(self)
      local reward = order.buy_sell_pane.pane.reward_tb
      reward.string = ""
      reward.text:set("")
    end

  self.reward_tb._keypressed = 
    function(self, key)  
      if not ((util.number_filter(key) ~= "") or (key == "backspace")) then 
        return
      end
      local price = order.buy_sell_pane.pane.price_tb
      if self.string == "" then 
        price.string = "" 
      else
        price.string = tostring(tonumber(self.string) * 1.10)
      end
      price.text:set(price.string)

      --set user vars
      user.reward =  tonumber(self.string) 
      user.risk =  tonumber(price.string)
    end

  self.reward_tb._onfocus = 
    function(self)
      local price = order.buy_sell_pane.pane.price_tb
      price.string = ""
      price.text:set("")
    end



  -- make bet button
  local bet_btn_on_press = function(self)
    local selected_team = (team1.selected and team1) or (team2.selected and team2)
    if not selected_team then
      print("Couldn't make bet: \nNo selected team!")
      return
    elseif not user.risk or not user.reward then
      print("Couldn't make bet: \nNo Risk or Reward!")
      return
    end
    --TODO adjust this to adhere to the spread chooser
    
    local new_bet = bet.new(selected_team,user.spread or "3", user.risk, user.reward, "pending" )
    table.insert(user.bets, new_bet)
    user.balance = user.balance - user.risk
  end

  self.bet_btn = button.new(self.w/4,self.reward_tb.y + 50, self.w/2, self.h/20,
                            {color.green, "make bet"}, {color.dark_green, "make bet"},
                            self.x + self.w/4, self.y + self.reward_tb.y + 50,
                            bet_btn_on_press )


  -- SPREAD buttons
--  self.spread_tb = tb.new( )

    
  -- SELL state things -------------------------------
  self.my_bets_label = lg.newText(sans_bold, "my bets:")

  self.sell_bet_btn = button.new(self.w/4, 7.5 * self.h/10, self.w/2, self.h/20 ,
                            {color.red, "sell bet"}, {color.dark_red, "sell bet"},
                            self.x + self.w/4, self.y + 7.5 * self.h/10,
                            function(self)
                              local sel_bet = false
                              for i,bet in pairs(user.bets) do
                                if bet.is_selected then
                                  sel_bet = bet
                                end
                              end
                              if not sel_bet then print("cannot sell bet: \nNo bet selected!") return end
                              --user.balance = user.balance + sel_bet.risk
                              table.remove(user.bets, util.find_e(user.bets, sel_bet))
			      table.insert(user.forsale_bets, sel_bet)
			      sel_bet.forsale = true
                              end)
                             

  ------------------------
end

--- state specific functions --------
local buy_state_update = function(self)
  --self.team1_switch:update()
  --self.team2_switch:update()
  self.bet_btn:update()
end
local buy_state_draw = function(self)
  self.team1_switch:draw()
  self.team2_switch:draw()
  self.price_tb:draw()
  self.reward_tb:draw()
  --draw labels for the tb's
  lg.setFont(sans_bold)
  lg.print("risk:",self.price_tb.x, self.price_tb.y - 15)
  lg.print("reward:",self.reward_tb.x, self.reward_tb.y - 15)
  --
  self.bet_btn:draw()
end

local buy_state_mousepressed = function(self, x, y, b)
  self.team1_switch:mousepressed(x, y, b)
  self.team2_switch:mousepressed(x, y, b)
  self.price_tb:mousepressed(x, y, b)
  self.reward_tb:mousepressed(x, y, b)

end

local buy_state_keypressed = function(self, key)
  self.price_tb:keypressed(key)
  self.reward_tb:keypressed(key)
end

local sell_state_update = function(self)
  self.sell_bet_btn:update()
end

local sell_state_draw = function(self)
  -- Draw the trade table:
  -- trade_table_mousepressed depends on this, if change there, change there too
  local sep = 30
  local lin_w = 2
  local x, y = sep, 3*self.h/10           
  local w, h = self.w - 2*sep, 4*self.h/10
  local bar_h = h/10 
  lg.setFont(sans_med)
  lg.setLineWidth(lin_w)
  lg.setColor(color.vlight)
  lg.stencil(function() lg.rectangle('fill', x, y, w, h) end, 'replace', 1)

  lg.setStencilTest("greater", 0)
  local cur_y = y + 1
  for i, bet in pairs(user.bets) do
    if bet.is_selected then
      lg.setColor(color.blue)  
    else
      lg.setColor(color.vlight)
    end

    lg.rectangle("fill", x, cur_y, w, bar_h)
    lg.setColor(color.white)
    lg.print(bet.winner.abbrev, x+2, cur_y)
    cur_y = cur_y + bar_h + 1
  end
  lg.setColor(color.vlight) 
  lg.rectangle("line", x, y,  w, h)
  lg.setStencilTest()
  -- end trade table
  
  lg.setColor(color.white) 
  lg.draw(self.my_bets_label, x, y - 16)

  self.sell_bet_btn:draw()
end

-- Checks to see which trade is selected
local trade_table_mousepressed = function(self, mousex, mousey, b)
  local sep = 30
  local lin_w = 2
  local x, y = sep + self.x , 3*self.h/10 + self.y
  local w, h = self.w - 2*sep, 4*self.h/10
  local bar_h = h/10 

  for i, bet in pairs(user.bets) do
    if (mousex  >= x and mousex  <= x + w) and
       (mousey  >= y + ((i-1)*bar_h + i)  and mousey  <= y + ((i)*bar_h + i)  ) then
      bet.is_selected = true 
      for i, b in pairs(user.bets) do
        if b ~= bet then
          b.is_selected = false
        end
      end
    end
  end
end


local sell_state_mousepressed = function(self, x, y, b)
  trade_table_mousepressed(self, x, y, b)
end
--- end state specific functions -------

local bsp_update = function(self)
  self.buy_switch:update()
  self.sell_switch:update()
  if self.buy_switch.pressed == true then
    buy_state_update(self)
  else
    sell_state_update(self)
  end
end

local bsp_mousepressed = function(self, x, y, b)
  self.buy_switch:mousepressed(x, y, b)
  self.sell_switch:mousepressed(x, y, b)
  if self.buy_switch.pressed == true then
    buy_state_mousepressed(self, x, y, b)
  else
    sell_state_mousepressed(self, x, y, b)
  end
end

local bsp_keypressed = function(self, key)
  if self.buy_switch.pressed == true then
    buy_state_keypressed(self, key)
  else
    --sell_state_keypressed(key) --idk if we need this yet TODO figure out
  end
end

local bsp_draw = function(self)
  lg.setColor(color.white)
  lg.draw(self.label, self.w/2 - self.label:getWidth()/2, 10 )
  self.buy_switch:draw()
  self.sell_switch:draw()
  lg.setColor(color.white)
  if self.buy_switch.pressed == true then
    buy_state_draw(self)
  else
    sell_state_draw(self)
  end

  lg.setColor(1,1,1)
end

--TODO fill in nil's with load and update funcs
bsp.pane = pane.new(bsp.x, bsp.y, bsp.w, bsp.h, bsp_load, bsp_update, bsp_draw, {'left', 'right', 'bottom'})
bsp.pane._mousepressed = bsp_mousepressed -- a secret field ;)
bsp.pane._keypressed = bsp_keypressed -- less exciting this time... eh


function order.load()
  --TODO move load functions here, then call them in love.resize
end


function order.update()

  order.balance_pane.pane:update()
  order.buy_sell_pane.pane:update()
end

function order.mousepressed(x, y, button)
  order.buy_sell_pane.pane:mousepressed(x, y, button)
end

function order.keypressed(key)
  order.buy_sell_pane.pane:keypressed(key)
end

function order.draw()
  order.balance_pane.pane:draw()
  order.buy_sell_pane.pane:draw()
end

return order
