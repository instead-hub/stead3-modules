local std = stead
local hooked = false
local orig_onwalk
local orig_afteract

local function writelog(s)
  local filename = "game.log"
  local f = io.open(filename, "a")
  f:seek("end", 0)
  f:write("\n", s, "\n")
  return f:flush()
end

std.mod_start(function()
  if hooked then
    return
  end
  orig_onwalk = std.rawget(game, 'onwalk');
  orig_afteract = std.rawget(game, 'afteract');  

  std.hook(game.onwalk, function(f, inwalk)
    print(inwalk.nam);
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
  end)

  std.hook(game.afteract, function(this, that)
    writelog("> "..this.nam..' @ '..that.nam)
    if that:type('phr') then
      writelog(std.call(that, 'dsc'))
    end
  end)
  hooked = true

  writelog("--- НАЧАЛО ИГРЫ ---")
end)

std.mod_done(function(load)
  hooked = false
  std.rawset(game, 'onwalk', orig_onwalk);
  std.rawset(game, 'afteract', orig_afteract);
end)
