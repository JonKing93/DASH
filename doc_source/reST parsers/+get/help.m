function[text] = help(name)

text = help(name);
eol = find(text==10);
comments = [1, eol(1:end-1)+1];
text(comments) = '%';

end
