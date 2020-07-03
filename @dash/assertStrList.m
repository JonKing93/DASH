function[] = assertStrList(input, name)
if ~isstrlist(input)
    error('%s must be a string vector or cellstring vector.', name);
end
end