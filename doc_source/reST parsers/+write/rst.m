function[] = rst(file, rst)
%% write.rst  Writes formatted RST text to a file
% ----------
%   write.rst(file, rst)
%   Writes the input RST text to the specified file
% ----------
%   Inputs:
%       file (string scalar): The absolute path to a file
%       rst (char vector): Formatted RST text
%
%   Outputs:
%       Writes the RST text to the file

fid = fopen(file, 'w');
closeFile = onCleanup( @()fclose(fid) );
rst = replace(rst, '\n', newline);
fprintf(fid, '%s', rst);

end