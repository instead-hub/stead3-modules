-- $Name: Transcript test$
-- instead_version "3.2.0"
loadmod "transcript"

declare 'make_path' (function(v) return path(v) end)

obj {
  nam = 'this';
  inv = 'This thing';
  use = 'As it should be.'
}
obj {
  nam = 'that';
  inv = 'That thing';
  use = 'Not the right way.'
}
take('this');
take('that');

room {
  nam = 'main';
  disp = 'Transcript start';
  dsc = [[
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam non massa in magna facilisis iaculis ut tincidunt nunc.
    Ut urna felis, congue quis ipsum id, blandit facilisis odio. Morbi ut lacinia tortor. Curabitur sagittis varius massa, et rutrum dolor placerat nec.
    In est tellus, vulputate vitae justo non, tempus rutrum dolor. 
    Quisque malesuada scelerisque metus, at sagittis tortor convallis at. 
    Fusce vitae metus lobortis, convallis erat eget, dictum leo. Proin in dolor bibendum, vehicula tellus a, congue nibh.
    Maecenas ut quam a est feugiat tristique. Vivamus id nunc metus.
  ]];
  way = { 'continue' }
}

room {
  nam = 'continue';
  way = { 'end' };
  disp = 'Transcript continued';
  decor = [[
    Aliquam erat volutpat.
    Fusce facilisis sem magna.

    Sed rhoncus elit malesuada lacus egestas imperdiet. Maecenas sapien sapien, sodales non auctor quis, interdum.
    Pellentesque ac feugiat leo. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.
  ]];
}

room {
  nam = 'end';
  disp = 'Transcript end';
  decor = [[
    Aenean eu ex pharetra urna maximus ultricies eu ut leo. 
    Cras convallis massa sapien.
    Integer turpis odio, fermentum sit amet leo at, pharetra vulputate velit. 
    In cursus est nisl, id vulputate arcu cursus in.
  ]];
}
