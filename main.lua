color = require('libs/color') --TODO make this local to every module
gui = require('libs/Gspot')
noise = require('libs/noise') --noise.Simplex2D(i,i)
local util = require('libs/util')
-- globals


team1 = {
  selected = false,
  abbrev = "NU",
  name = "Northestern",
  score = 0,
}
team2 = {
  selected = false,
  abbrev = "MIN",
  name = "Minesota",
  score = 0,
}

-- TODO add button width, button height !!!, make everythong use it
ui = {
  btn_w = nil,
  btn_h = nil,

  border_width = 2,
  bg_color = color.dark,
  fg_color = color.light,
  roundness = 0,
}

user = {
  balance = 1000,
  buy_price = 0,
  risk = 0,
  reward = 0,
  bets = {}, --holds all current bets that arent for sale
  forsale_bets = {}, -- all bets for sale
  done_bets = {},
  selected_bet = nil, -- initalized, check "if slected_bet then ..."
  spread = 3,
  ratio = 1.10, --the odds or something idk? risk = reward * user.ratio
  game_len = 5 * 60, --40min college baskball in sec. (5 min so faster)
}

lg = love.graphics
lk = love.keyboard

sans = lg.newFont('open_sans.ttf', 20)
sans_small = lg.newFont('open_sans.ttf', 10)
sans_med = lg.newFont('open_sans.ttf', 15)
sans_bold = lg.newFont('open_sans_bold.ttf', 13)

local order_form = require('order_form/order_form')
local bet = require('bet')
local order_book = require('order_book/order_book') --aka 'book'
local line_graph = require('line_graph/line_graph')
local play_by_play = require('play_by_play/play') --only draw!
local my_orders = require('my_orders/my_orders')
-- etc.

assert(line_graph ~= nil)

-- mult 255 colors by DIV
local DIV = love._version_major >= 11 and 1/255 or 1 



function love.load()
  math.randomseed(os.time())
  lg.setLineWidth(10)
  order_book.load()
  line_graph.load()
end



function love.update(dt)
  --gui:update(dt) 
  order_form.update()
  order_book.update(dt)
  line_graph.update(dt)
  
  --TODO remove block v
  for i, bet in pairs(user.bets) do
     if bet.forsale then
	bet.lifetime = bet.lifetime + dt 
	if (not bet.paid_out) and bet.lifetime > bet.deathtime then
	  bet.state = 'finished' --i.e. 'SOLD'
	  user.balance = user.balance + bet.reward + bet.risk
	  bet.paid_out = true
	end
     end
  end

for i, bet in pairs(user.forsale_bets) do
     if bet.forsale then
	bet.lifetime = bet.lifetime + dt 
	  if bet.lifetime > bet.deathtime then
	  bet.state = 'finished' --i.e. 'SOLD'
          table.remove(user.forsale_bets, util.find_e(user.forsale_bets, bet))
	  table.insert(user.done_bets, bet)
	  user.balance = user.balance + bet.risk
	end
     end
  end

end

function love.mousepressed( x, y, button)
  order_form.mousepressed(x, y, button)
  order_book.mousepressed(x, y, button)
  my_orders.mousepressed(x, y, button)
end

function love.draw()
  lg.clear(ui.bg_color)
  order_form.draw()
  order_book.draw()
  line_graph.draw()
  play_by_play.draw()
  my_orders.draw()
end


function love.keypressed(key)
  order_form.keypressed(key)
  order_book.keypressed(key)
  if key == 'escape' then love.event.quit() end --TODO remove on build, only for debug
  if key == 'tab'    then love.event.quit('restart') end

  --TODO remove on build, only for debug
  if key == 'up'     then user.spread = user.spread + 5 end
  if key == 'down'   then user.spread = user.spread - 5 end
end
