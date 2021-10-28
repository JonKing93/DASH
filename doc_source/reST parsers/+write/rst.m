function[] = rst(file, rst)

fid = fopen(file, 'w');
closeFile = onCleanup( @()fclose(fid) );
fprintf(fid, rst);

end