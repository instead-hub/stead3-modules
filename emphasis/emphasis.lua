require 'format'

format.filter = function(text)
  for _, s in ipairs {"%*%*", "%_%_"} do
    text = text:gsub(s .. "([^%s][^<>]-[^%s][%*%_]?)" .. s, txtb("%1"));
  end;
  for _, s in ipairs {"%*"} do
    text = text:gsub(s .. "([^%s_][^<>_]-[^%s_])" .. s, txtem("%1"));
  end;
  for _, s in ipairs {"%_"} do
    text = text:gsub(s .. "([^%s_][^<>_]-[^%s_])" .. s, txtu("%1"));
  end;
  for _, s in ipairs {"%-"} do
    text = text:gsub(s .. " ([^%s_][^<>_]-[^%s_]) " .. s, txtst("%1"));
  end;
  return text;
end
