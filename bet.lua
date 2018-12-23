local bet = {
  max = 500000,
  min = 100
}

bet.meta = {
  __index = bet,
}

function bet.new(winner, spread, risk, reward, state, is_real)
  assert(risk)
  assert(reward)
  local new = {
    winner = winner,
    spread = spread,
    risk = risk,
    current_value = risk,
    reward = reward,
    is_selected = false,
    state = state or "pending", --won, lost, sold
    forsale = false,
    paid_out = false,
    deathtime = math.random(10),
    lifetime = 0, --how longhas it been alive
  }

  --the and/or trick doesnt work for boolean :( 
  if is_real == nil then
    is_real = true
  end

  return setmetatable(new, bet.meta)
end


return bet
