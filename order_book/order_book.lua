
local lg = love.graphics
local lm = love.mouse

----------------

local timer = require('libs/timers')
local util = require('libs/util')
local pane = require('pane')
local timer = require('libs/timers')
local bet = require('bet')

----------------

local book = {
  x = 214,
  y = 75,
  w = 250,--214, --same as order_form
  h = 800-75,
}
local label_p = {
  x = book.x,
  y = 0,
  w = book.w,
  h = 75,
}

local old_spread = user.spread


local fake_bets = {}

-- contain sorted lists of bets, for top or btm of order book
local top_bets = {} 
local btm_bets = {}

-- [[
-- divide bets between top and bottom
-- sort individual tables
-- ]]
local sort_bets = function()
  top_bets = {}
  btm_bets = {}
  local mid = (bet.max - bet.min)/2
  for i,v in pairs(fake_bets) do
    if v.risk > mid then
      table.insert(top_bets, v) --, v)
    else
      table.insert(btm_bets, v)--, v)
    end
  end
  local tbsf = function(b1, b2) return b1.risk < b2.risk end
  local bbsf = function(b1, b2) return b1.risk > b2.risk end
  table.sort(top_bets, tbsf)
  table.sort(btm_bets, bbsf)
end

-- ORDER BOOK PANE functions

local book_load = function(self)
  self.new_bet_timer = timer.new(0.2,
  function(self)
      self:restart()
      local team = ((math.random(0,1) > 0.5) and team1 or team2)
      local spread = user.spread
      local risk = math.random(bet.min, bet.max) + math.random(00,99)/100
      local reward = math.floor((risk * 1/user.ratio) * 100)/100 --math.random(low, high)()
      table.insert(fake_bets, bet.new(team, spread, risk, reward, nil, false))
      sort_bets()
     end, false)

  self.del_bet_timer = timer.new(0.7,
  function(self)
    self.duration = math.random(1, 20)/10
    self:restart()
    table.remove(fake_bets, util.find_e( fake_bets, top_bets[1]))
    table.remove(fake_bets, util.find_e( fake_bets, btm_bets[1]))
    sort_bets()
   end, false)

  
  --fill fake bets
  local low, high = bet.min, bet.max
  for i = 1, 100 do
    local team = ((math.random(0,1) > 0.5) and team1 or team2)
    local spread = user.spread
    local risk = math.random(low, high) + math.random(00,99)/100
    local reward = math.floor((risk * 1/user.ratio) * 100)/100 --math.random(low, high)
    fake_bets[i] = bet.new(team, spread, risk, reward, nil, false)
  end
  sort_bets()
end


local book_update = function(self,dt) 
  --TODO make a new bet using a timer, call timer:update etc.
  self.new_bet_timer:update(dt)
  self.del_bet_timer:update(dt)

  if old_spread ~= user.spread then
    diff = user.spread - old_spread
    old_spread = user.spread
--    bet.min = bet.min + diff
--    bet.max = bet.max + diff
    for i,v in pairs(fake_bets) do
      v.risk = v.risk + diff
      v.reward = v.risk * 1/user.ratio --wrong maybe? this doesn't really matter
    end
  end

  if #fake_bets < 100 then 
    local low, high = bet.min, bet.max
    for i = 1, 100 do
      local team = ((math.random(0,1) > 0.5) and team1 or team2)
      local spread = user.spread
      local risk = math.random(low, high) + math.random(00,99)/100
      local reward = math.floor((risk * 1/user.ratio) * 100)/100 --math.random(low, high)
      fake_bets[i] = bet.new(team, spread, risk, reward, nil, false)
    end
  end
end


local book_draw = function(self)
  
 
  
  -- Draw eaach bet as a bar first, then draw the box around them 
  local sep = 15 -- separation from pane border

  local bar_h = 24
  local bar_w = self.h - 2*sep

  local half_height = (self.h - 2*sep)/2  --385

  lg.stencil(function() 
              lg.rectangle('fill', sep, sep , self.w - 2*sep,self.h - 2*sep) 
             end, 
             'replace', 1)
  lg.setStencilTest("greater", 0)

  -- DRAW DIVIDER BAR
  local divy, divh = sep + half_height - bar_h, bar_h*2
  lg.setColor(color.dark)
  lg.rectangle('fill', sep, divy, self.w - 2*sep, divh)
  lg.setColor(color.vlight)
  lg.rectangle('line', sep, divy, self.w - 2*sep, divh)
  lg.setColor(color.white)
  lg.setFont(sans)
  lg.print("Spread\t " ..  tostring(user.spread) .. " : ".. tostring(-user.spread), sep + 10, divy + 8)

  local top_end = divy - 2*bar_h 
  local btm_start = divy + divh

  -- Draw TOP, from the btm to the top
  local j = 1
  for i = top_end + bar_h, 0, -bar_h do
    j = j + 1
    local x = sep
    local y = i
    local w = self.w - 2 *sep
    local h = bar_h
    local bet = top_bets[j]
    assert(bet ~= nil, "no top bet #" .. tostring(j))
    local word_sep = 75
    lg.setColor(color.vlight)
    lg.rectangle('line', x, y, w, h)
    lg.setFont(sans_med)
    lg.setColor(color.white) 
    lg.print(bet.winner.abbrev, x + 8, y  )
    lg.setColor(color.red)   ; lg.print(bet.risk, x + word_sep - 28, y )
    
  end

  -- Draw BTM, from the top to the btm
  local j = 1
  for i = btm_start, self.h, bar_h do
    j = j + 1
    local x = sep
    local y = i
    local w = self.w - 2 *sep
    local h = bar_h
    local bet = btm_bets[j] --TODO add logic here and above 
    assert(bet ~= nil, "no btm bet #" .. tostring(j))
    local word_sep = 75
    lg.setColor(color.vlight)
    lg.rectangle('line', x, y, w, h)

    lg.setFont(sans_med)
    lg.setColor(color.white)
    lg.print(bet.winner.abbrev, x + 8, y  )
    lg.setColor(color.green)   ; lg.print(bet.risk, x + word_sep - 28, y )
    
  end

  lg.setStencilTest()

  lg.setLineWidth(2)
  lg.setColor(color.vlight)
  lg.rectangle('line', sep, sep, self.w - 2*sep, self.h - 2*sep)
end

-- LABEL PANE funtions

label_p_load = function(self)
  self.label = lg.newText(sans, "Order Book")
end


label_p_draw = function(self)
  lg.setColor(color.white)
  lg.draw(self.label, self.w/2 - self.label:getWidth()/2, self.h/2 - self.label:getHeight()/2)
end





book.label_pane = pane.new(label_p.x, label_p.y, label_p.w, label_p.h,
                            label_p_load, nil, label_p_draw,
                            {'top','right'})

book.pane = pane.new( book.x, book.y, book.w, book.h,
                            book_load, book_update, book_draw,
                            {'top', 'right', 'bottom'})



function book.load()
  
end


function book.update(dt)
  book.pane:update(dt)
end


function book.mousepressed(x, y, button)
  book.pane:mousepressed(x, y, button)
end


function book.keypressed(key)
  book.pane:keypressed(key)
end


function book.draw()
  book.label_pane:draw()
  book.pane:draw()
end

return book
