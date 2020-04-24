local function autodetect_theme()
	if not instead.screen_size then
		return
	end
	local f = io.open(instead.savepath().."/config.ini", "r")
	if f then
		f:close()
		return
	end
	f = io.open(instead.gamepath().."/themes/default/theme.ini", "r")
	if not f then
		return
	end
	f:close()

	local themes = {}
	local vertical = false
	for d in std.readdir(instead.gamepath().."/themes") do
		if d ~= '.' and d ~= '..' then
			local p = instead.gamepath().."/themes/" .. d
			local f = io.open(p.."/theme.ini", "r")
			if f then
				local w, h
				for l in f:lines() do
					if l:find("scr%.w[ \t]*=[ \t]*[0-9]+") then
						w = l:gsub("scr%.w[ \t]*=[ \t]*([0-9]+)", "%1")
					elseif l:find("scr%.h[ \t]*=[ \t]*[0-9]+") then
						h = l:gsub("scr%.h[ \t]*=[ \t]*([0-9]+)", "%1")
					end
					if w and h then break end
				end
				if w and h then
					w = tonumber(w)
					h = tonumber(h)
					local r = w / h
					if r < 1 then r = 1 / r end
					table.insert(themes, { nam = d, w = w, h = h, mobile = w < h, ratio = r })
					vertical = vertical or (w < h)
				end
				f:close()
			end
		end
	end

	if #themes == 1 then
		return
	end
	local w, h = instead.screen_size()
	local r = w / h
	local mobile = w < h or PLATFORM == "ANDROID" or PLATFORM == "IOS" or PLATFORM == "S60" or PLATFORM == "WINRT" or PLATFORM == "WINCE"
	if w < h then
		r = 1 / r
	end
	local d = 1000
	local t = false
	for _, v in ipairs(themes) do
		local dd = math.abs(v.ratio - r)
		if dd < d then
			if mobile and (not vertical or v.mobile) then
				d = dd
				t = v
			elseif not mobile and not v.mobile then
				d = dd
				t = v
			end
		end
	end
	if not t or t.nam == 'default' then
		return
	end
	local name = instead.savepath().."/config.ini"
	local name_tmp = name .. '.tmp'
	local f = io.open(name_tmp, "w")
	if f then
		dprint("Autodetect theme: ", t.nam)
		f:write("theme = "..t.nam.."\n")
		f:close()
		std.os.remove(name)
		std.os.rename(name_tmp, name);
		instead.restart()
	end
end

std.mod_start(function()
	autodetect_theme()
end, -100)
