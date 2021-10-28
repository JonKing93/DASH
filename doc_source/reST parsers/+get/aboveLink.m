function[header] = aboveLink(header)

title = parse.h1(header);
doclink = sprintf('<a href="matlab:dash.doc(''%s'')">Documentation Page</a>', title);
linkIndex = strfind(header, doclink);

assert(numel(linkIndex)<2)
if ~isempty(doclink)
    header = header(1:linkIndex-1);
end

end