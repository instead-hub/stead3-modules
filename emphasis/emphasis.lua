require 'fmt'

fmt.filter = function(text)
  for _, s in ipairs {"%*%*", "%_%_"} do
    text = text:gsub(s .. "([^%s][^<>]-[^%s][%*%_]?)" .. s, fmt.b("%1"));
  end;
  for _, s in ipairs {"%*"} do
    text = text:gsub(s .. "([^%s_][^<>_]-[^%s_])" .. s, fmt.em("%1"));
  end;
  for _, s in ipairs {"%_"} do
    text = text:gsub(s .. "([^%s_][^<>_]-[^%s_])" .. s, fmt.u("%1"));
  end;
  for _, s in ipairs {"%-"} do
    text = text:gsub(s .. "([^%s_][^<>_]-[^%s_])" .. s, fmt.st("%1"));
  end;
  return text;
end
