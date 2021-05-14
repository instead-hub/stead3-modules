--[[
Code obfuscator

Usage:
lua protect.lua infile outfile
Or:
sdl-instead -lua protect.lua infile outfile
]]--

local eval
if _VERSION ~= "Lua 5.1" then
	eval = load
else
	eval = loadstring
end
local encoder = eval[=====[local a=string.char;local type=type;local select=select;local b=string.sub;local c=table.concat;local d={}local e={}for f=0,255 do local g,h=a(f),a(f,0)d[g]=h;e[h]=g end;function add(i,j)return(i+j)%256 end;local function k(l,m,i,j)if i>=256 then i,j=0,j+1;if j>=256 then m={}j=1 end end;m[l]=a(i,j)i=i+1;return m,i,j end;local function n()local o=[====[(function(a)local b=string.char;local type=type;local select=select;local c=string.sub;local d=table.concat;local e='Depacker v1.0'local f={}local g={}local h=e:sub(2,2)for i=0,255 do local j,k=b(i),b(i,0)f[j]=k;g[k]=j end;local l='st'local function m(n,o,p,q)if p>=256 then p,q=0,q+1;if q>=256 then o={}q=1 end end;o[b(p,q)]=n;p=p+1;return o,p,q end;h=h..e:sub(10,10)local r='get'local s=2;local t=std.eval([[return 'source']])local function u(v)local w=0;local x=std.getinfo(v,"S")if x.source and string.sub(x.source,1,1)=="@"then local y=string.sub(x.source,2)local i=0;for z in io.lines(y)do i=i+1;if i>x.lastlinedefined then break end;if i>=x.linedefined then for i=1,z:len()do w=(w+string.byte(z,i))%0x100000 end end;s=s^2 end end;return w end;local A=0x50;local B=_G;h=h..e:sub(4,4)local function C(p,q)return math.floor((256+p-q)%256)end;r=r..'info'local w=u(2)l=l..'d'local function D(E)local F=''for i=1,E:len()do F=F..string.char(C(string.byte(E,i),w))end;return F end;A=A+1;h=h..'l'local x=std.getinfo(2,"S")local v=io.open(x.source:sub(2),"rb")if not v then error"No file!"end;while v:read("*l"):find('--[===[',1,true)~=1 do end;a=v:read("*all"):sub(1,-10)A=A+1;v:close()A=string.char(A+1)w=w+(#B[l][r](B[l][h],A)[t()]~=#h and#a or 0)a=D(a)if type(a)~="string"then error("string expected, got "..type(a))end;if#a<1 then error("invalid input - not a compressed string")end;local G=c(a,1,1)if G=="u"then return _(c(a,2))elseif G~="c"then error"invalid input - not a compressed string"end;a=c(a,2)local H=#a;local _=_G[l][h]if H<2 then error"invalid input - not a compressed string"end;local o={}local p,q=0,1;local I={}local J=1;local K=c(a,1,2)I[J]=g[K]or o[K]J=J+1;for i=3,H,2 do local L=c(a,i,i+1)local M=g[K]or o[K]if not M then error"could not find last from dict. Invalid input?"end;local N=g[L]or o[L]if N then I[J]=N;J=J+1;o,p,q=m(M..c(N,1,1),o,p,q)else local O=M..c(M,1,1)I[J]=O;J=J+1;o,p,q=m(O,o,p,q)end;K=L end;_(d(I))()end)()]====]local p=0;local q=string.format("local IiIiI='%d'",math.random(0x10000000))local r=''o=o:gsub("^%(function%(([^)]+)%)","(function(%1)"..q)for f=1,o:len()do p=(p+string.byte(o,f))%0x100000 end;r=r..o..'\n'return p,r end;local function s(t)if type(t)~="string"then error("string expected, got "..type(t))end;local p,r=n()local u=#t;if u<=1 then error"Len is too small"end;local m={}local i,j=0,1;local v={"c"}local w=1;local x=2;local y=""local function z(A)local o=''for f=1,A:len()do o=o..string.char(add(string.byte(A,f),p))end;return o end;for f=1,u do local B=b(t,f,f)local C=y..B;if not(d[C]or m[C])then local D=d[y]or m[y]if not D then error"algorithm error, could not fetch word"end;v[x]=D;w=w+#D;x=x+1;m,i,j=k(C,m,i,j)y=B else y=C end end;v[x]=d[y]or m[y]w=w+#v[x]x=x+1;return z(c(v)),r end;return{compress=s}]=====]()

function encode(file, ofile)
	local f, e = io.open(file, "rb")
	if not f then
		error(e)
	end
	local data = ''
	local h = ''
	for l in f:lines() do
		data = data .. l .. '\n'
		if not l:find("^[ \t]*%-%-") and not l:find("^[ \t]*$") then
			break
		end
		h = h .. l..'\n'
	end
	data = data .. f:read("*all")
	f:close()

	local compressed, app = encoder.compress(data)

	local o, e = io.open(ofile, "wb")
	if not o then
		error(e)
	end
	o:write(app)
	o:write("--[===[\n")
	o:write(compressed)
	o:write("\n]===]--\n")
	o:close()
end
local args = {...}

if #args < 2 then
	print("Usage: <infile> <outfile>")
	os.exit(1)
end

encode(args[1], args[2])
