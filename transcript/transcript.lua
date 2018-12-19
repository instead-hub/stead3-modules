local std = stead
local filename = "game.log"

function writelog(s)
  local f = io.open(filename, "a")
  f:seek("end", 0)
  f:write("\n", s, "\n")
  return f:flush()
end

game.onwalk = function(f, inwalk)
  if inwalk.dsc then
    local dsc = std.call(inwalk, 'dsc')
    if dsc then
      writelog(dsc)
    end
  end
  if inwalk.decor then
    local decor = std.call(inwalk, 'decor')
    if decor then
      writelog(decor)
    end
  end
  return true
end

game.afteract = function(this, that)
  local nam1 = this.decor
  local nam2 = that.decor
  if that:type('phr') then
    nam2 = std.call(that, 'dsc')
  else
    nam2 = that.nam
  end
  if nam2 then
    writelog("> "..nam2)
  end
end

std.mod_start(function() writelog("--- НАЧАЛО ИГРЫ ---") end)
