function[info] = nonscalarObj(obj, type)

N = ndims(obj);
if N < 5
    siz = dash.string.size(size(obj));
else
    siz = sprintf('%.f-D', N);
end

if isempty(obj)
    empty = 'empty ';
else
    empty = '';
end

info = sprintf('  %s %s%s array\n\n', siz, empty, type);

end