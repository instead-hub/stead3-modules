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
local encoder = eval[======[local a=[===[(function(a)local b=string.char;local type=type;local select=select;local c=string.sub;local d=table.concat;local e='Depacker v1.0'local f={}local g={}local h=e:sub(2,2)for i=0,255 do local j,k=b(i),b(i,0)f[j]=k;g[k]=j end;local l='st'local function m(n,o,p,q)if p>=256 then p,q=0,q+1;if q>=256 then o={}q=1 end end;o[b(p,q)]=n;p=p+1;return o,p,q end;h=h..e:sub(10,10)local function r(s)local t=0;local u=std.getinfo(s,"S")if u.source and string.sub(u.source,1,1)=="@"then local v=string.sub(u.source,2)local i=0;for w in io.lines(v)do i=i+1;if i>u.lastlinedefined then break end;if i>=u.linedefined then for i=1,w:len()do t=(t+string.byte(w,i))%0x100000 end end end end;return t end;h=h..e:sub(4,4)local function x(p,q)return math.floor((256+p-q)%256)end;local t=r(2)l=l..'d'local function y(z)local A=''for i=1,z:len()do A=A..string.char(x(string.byte(z,i),t))end;return A end;h=h..'l'local u=std.getinfo(2,"S")local s=io.open(u.source:sub(2),"rb")if not s then error"No file!"end;while s:read("*l"):find('--[===[',1,true)~=1 do end;a=s:read("*all"):sub(1,-10)a=y(a)if type(a)~="string"then error("string expected, got "..type(a))end;if#a<1 then error("invalid input - not a compressed string")end;local B=c(a,1,1)if B=="u"then return _(c(a,2))elseif B~="c"then error"invalid input - not a compressed string"end;a=c(a,2)local C=#a;local _=_G[l][h]if C<2 then error"invalid input - not a compressed string"end;local o={}local p,q=0,1;local D={}local E=1;local F=c(a,1,2)D[E]=g[F]or o[F]E=E+1;for i=3,C,2 do local G=c(a,i,i+1)local H=g[F]or o[F]if not H then error"could not find last from dict. Invalid input?"end;local I=g[G]or o[G]if I then D[E]=I;E=E+1;o,p,q=m(H..c(I,1,1),o,p,q)else local J=H..c(H,1,1)D[E]=J;E=E+1;o,p,q=m(J,o,p,q)end;F=G end;_(d(D))()end)()]===]local b=string.char;local type=type;local select=select;local c=string.sub;local d=table.concat;local e={}local f={}for g=0,255 do local h,i=b(g),b(g,0)e[h]=i;f[i]=h end;function add(j,k)return(j+k)%256 end;local function l(m,n,j,k)if j>=256 then j,k=0,k+1;if k>=256 then n={}k=1 end end;n[m]=b(j,k)j=j+1;return n,j,k end;local function o()local p=0;local q=string.format("local IiIiI='%d'",math.random(0x10000000))local r=''local s=a:gsub("^%(function%(([^)]+)%)","(function(%1)"..q)for g=1,s:len()do p=(p+string.byte(s,g))%0x100000 end;r=r..s..'\n'return p,r end;local function t(u)if type(u)~="string"then error("string expected, got "..type(u))end;local p,r=o()local v=#u;if v<=1 then error"Len is too small"end;local n={}local j,k=0,1;local w={"c"}local x=1;local y=2;local z=""local function A(B)local s=''for g=1,B:len()do s=s..string.char(add(string.byte(B,g),p))end;return s end;for g=1,v do local C=c(u,g,g)local D=z..C;if not(e[D]or n[D])then local E=e[z]or n[z]if not E then error"algorithm error, could not fetch word"end;w[y]=E;x=x+#E;y=y+1;n,j,k=l(D,n,j,k)z=C else z=D end end;w[y]=e[z]or n[z]x=x+#w[y]y=y+1;return A(d(w)),r end;return{compress=t}]======]()

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
