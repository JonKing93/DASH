function[] = rst(file, rst)

fid = fopen(file, 'w');
closeFile = onCleanup( @()fclose(fid) );
rst = replace(rst, '\n', newline);
fprintf(fid, '%s', rst);

end