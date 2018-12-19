global 'translate' ({})
-- redefine to set source language
translate.source = 'ru';

-- Credit: http://lua-users.org/lists/lua-l/2010-04/msg00005.html
local function load_mo_file(mo_file)
  --------------------------------
  -- open file and read data
  --------------------------------
  local fd,err=io.open(mo_file,"rb")
  if not fd then return nil,err end
  local mo_data=fd:read("*all")
  fd:close()

  --------------------------------
  -- precache some functions
  --------------------------------
  local byte=string.byte
  local sub=string.sub

  --------------------------------
  -- check format
  --------------------------------
  local peek_long --localize
  local magic=sub(mo_data,1,4)
  -- intel magic 0xde120495
  if magic=="\222\018\004\149" then
    peek_long=function(offs)
      local a,b,c,d=byte(mo_data,offs+1,offs+4)
      return ((d*256+c)*256+b)*256+a
    end
  -- motorola magic = 0x950412de
  elseif magic=="\149\004\018\222" then
    peek_long=function(offs)
      local a,b,c,d=byte(mo_data,offs+1,offs+4)
      return ((a*256+b)*256+c)*256+d
    end
  else
    return nil,"no valid mo-file"
  end

  --------------------------------
  -- version
  --------------------------------
  local V=peek_long(4)
  if V~=0 then
    return nil,"unsupported version"
  end

  ------------------------------
  -- get number of offsets of table
  ------------------------------
  local N,O,T=peek_long(8),peek_long(12),peek_long(16)
  ------------------------------
  -- traverse and get strings
  ------------------------------
  local hash={}
  for nstr=1,N do
    local ol,oo=peek_long(O),peek_long(O+4) O=O+8
    local tl,to=peek_long(T),peek_long(T+4) T=T+8
    hash[sub(mo_data,oo+1,oo+ol)]=sub(mo_data,to+1,to+tl)
  end
  return hash
end

translate.init = function()
  if not LANG then
    LANG = "en"
  end

  if LANG == translate.source then
    __ = function(text)
      return text;
    end;
  else
    print(LANG);
    print(translate.source);
    translate.strings = load_mo_file('translations/' .. LANG .. '.mo');
    if translate.strings == nil then
      error("translation not found")
    end
    __ = function(text)
      if translate.strings[text] ~= nil then
        return translate.strings[text];
      end;
      return text;
    end
  end
end
