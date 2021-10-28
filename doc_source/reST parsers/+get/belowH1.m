function[text, eol] = belowH1(header)

eol = find(header==10);
if numel(eol)<3
    text = '';
    eol = [];
else
    line3 = eol(2)+1;
    text = header(line3:end);
    eol = eol(3:end) - eol(2);
end

end