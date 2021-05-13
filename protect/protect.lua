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
local encoder = eval[======[local a=string.char;local type=type;local select=select;local b=string.sub;local c=table.concat;local d={}local e={}for f=0,255 do local g,h=a(f),a(f,0)d[g]=h;e[h]=g end;function add(i,j)return(i+j)%256 end;local function k(l,m,i,j)if i>=256 then i,j=0,j+1;if j>=256 then m={}j=1 end end;m[l]=a(i,j)i=i+1;return m,i,j end;local function n()local o=[=====[(function(a)local b=string.char;local type=type;local select=select;local c=string.sub;local d=table.concat;local e='Depacker v1.0'local f={}local g={}local h=e:sub(2,2)for i=0,255 do local j,k=b(i),b(i,0)f[j]=k;g[k]=j end;local l='st'local function m(n,o,p,q)if p>=256 then p,q=0,q+1;if q>=256 then o={}q=1 end end;o[b(p,q)]=n;p=p+1;return o,p,q end;h=h..e:sub(10,10)local function r(s)local t=0;local u=std.getinfo(s,"S")if u.source and string.sub(u.source,1,1)=="@"then local v=string.sub(u.source,2)local i=0;for w in io.lines(v)do i=i+1;if i>u.lastlinedefined then break end;if i>=u.linedefined then for i=1,w:len()do t=(t+string.byte(w,i))%0x100000 end end end end;return t end;h=h..e:sub(4,4)local function x(p,q)return math.floor((256+p-q)%256)end;local t=r(2)l=l..'d'local function y(z)local A=''for i=1,z:len()do A=A..string.char(x(string.byte(z,i),t))end;return A end;h=h..'l'local u=std.getinfo(2,"S")local s=io.open(u.source:sub(2),"rb")if not s then error"No file!"end;while s:read("*l"):find('--[===[',1,true)~=1 do end;a=s:read("*all"):sub(1,-10)s:close()a=y(a)if type(a)~="string"then error("string expected, got "..type(a))end;if#a<1 then error("invalid input - not a compressed string")end;local B=c(a,1,1)if B=="u"then return _(c(a,2))elseif B~="c"then error"invalid input - not a compressed string"end;a=c(a,2)local C=#a;local _=_G[l][h]if C<2 then error"invalid input - not a compressed string"end;local o={}local p,q=0,1;local D={}local E=1;local F=c(a,1,2)D[E]=g[F]or o[F]E=E+1;for i=3,C,2 do local G=c(a,i,i+1)local H=g[F]or o[F]if not H then error"could not find last from dict. Invalid input?"end;local I=g[G]or o[G]if I then D[E]=I;E=E+1;o,p,q=m(H..c(I,1,1),o,p,q)else local J=H..c(H,1,1)D[E]=J;E=E+1;o,p,q=m(J,o,p,q)end;F=G end;_(d(D))()end)()]=====]local p=0;local q=string.format("local IiIiI='%d'",math.random(0x10000000))local r=''o=o:gsub("^%(function%(([^)]+)%)","(function(%1)"..q)for f=1,o:len()do p=(p+string.byte(o,f))%0x100000 end;r=r..o..'\n'return p,r end;local function s(t)if type(t)~="string"then error("string expected, got "..type(t))end;local p,r=n()local u=#t;if u<=1 then error"Len is too small"end;local m={}local i,j=0,1;local v={"c"}local w=1;local x=2;local y=""local function z(A)local o=''for f=1,A:len()do o=o..string.char(add(string.byte(A,f),p))end;return o end;for f=1,u do local B=b(t,f,f)local C=y..B;if not(d[C]or m[C])then local D=d[y]or m[y]if not D then error"algorithm error, could not fetch word"end;v[x]=D;w=w+#D;x=x+1;m,i,j=k(C,m,i,j)y=B else y=C end end;v[x]=d[y]or m[y]w=w+#v[x]x=x+1;return z(c(v)),r end;return{compress=s}]======]()

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
