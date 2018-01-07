require "fmt"

instead.version(3, 2)

obj {
	nam = '$link';
	act = function(s, w)
		if instead.clipboard() ~= w then
			std.p ('{@link ', w, '|', w, '}')
		else
			std.p(fmt.u (w) ..' [в буфере обмена]')
		end
	end;
}

obj {
	nam = '@link';
	act = function(s, w)
		instead.clipboard(w)
	end;
}
