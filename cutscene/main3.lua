require "cutscene"
require "fmt"

cutscene {
	nam = 'main';
	decor = function()
		pn (fmt.c("INSTEAD"))
		pn "[fading 16]"
		pn (fmt.c("http://instead.syscall.ru"))
		pn "[code print 'hello']"
		pn "2017"
		pn "[cut]"
		pn "Март"
	end;
}
