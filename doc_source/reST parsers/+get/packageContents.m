function[contents] = packageContents(help)
eol = find(help==10);
k = get.lastUsageLine(help, eol);
contents = help(eol(k)+1:end);
end