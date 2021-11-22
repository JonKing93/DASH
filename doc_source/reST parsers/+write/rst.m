function[] = rst(file, rst)

fid = fopen(file, 'w');
closeFile = onCleanup( @()fclose(fid) );

% Escape non-escaped backslash
rst = char(rst);
escapes = regexp(rst, '\\[^n]');
for e = numel(escapes):-1:1
    rst = [rst(1:escapes(e)), '\', rst(escapes(e)+1:end)];
end

% Replace comments with %%
rst = replace(rst, '%', '%%');

% Print to file
fprintf(fid, rst);

end