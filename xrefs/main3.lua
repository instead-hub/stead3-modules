loadmod 'xrefs'

obj {
	nam = 'apple2';
	disp = 'piece of apple';
	inv = function(s) p 'Eaten!'; remove(s) end;
	use = 'Hmm...';
}

room {
	nam = 'main';
	title = 'xrefs demo';
	dsc = [[Press key to activate item. Press shift+key1, then key2 - to use item1 on item2.]];
	obj = {
		obj {
			nam = 'apple';
			dsc = '{Apple}.';
			tak = "Taken.";
			inv = "Do not want to eat!";
			use = function(s, w)
				p [[Hmmm.. Not usable.]];
			end;
		};
		obj {
			nam = 'knife';
			dsc = '{Knife}';
			tak = "Taken.";
			inv = "Do not hurt yourself!";
			use = function(s, w)
				if w ^ 'apple' then
					p [[Hehe....]]
					take 'apple2'
				else
					p [[Hmmm.. Not usable.]];
				end
			end;
		};
	};
}
