local util = {}


function util.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end


-- takes a string, returns true if it is a number, false if not
function util.number_filter(c)
  local nums = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'  }
  if util.contains(nums, c) then
    return c
  else
    return ""
  end
end


--removes element e from table t
function util.remove_e(t, e) 
  for i, v in pairs(t) do
    if v == e then
      t[i] = nil
    end
  end
end


function util.find_e(t, e)
  for i,v in pairs(t) do
    if e == v then
      return i
    end
  end
end


-- shifts a list back so that it doesn;t have a bunch of nils at the front
-- TODO I think this has a bug idk
function util.shift_back(t)
  local front_found = false
  local front = 0
  for i, v in pairs(t) do
    if not front_found then
      if i ~= nil then
        front_found = true
        front = i
      end
    else --front has been found
      if i == nil then break end
      t[i - front] = t[i]
    end
  end
  return front
end


return util
