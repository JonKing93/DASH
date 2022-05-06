function[] = functionRST(title, examplesFile, saveIn)
%% write.functionRST  Writes the RST file for a function
% ----------
%   write.functionRST(title, examplesFile, saveIn)
%   Combines function help text with an examples markdown file (if
%   available) to create a RST file for the function. Write the RST file to
%   the specified location.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing name of the function
%       examplesFile (string scalar(: The absolute path to the markdown
%           examples file for the function.
%       saveIn (string scalar): The absolute path to the folder that should
%           hold the RST file for the function.
%
%   Outputs:
%       Writes the RST file for a function to the specified location

% Defaults
if ~exist('examplesFile','var')
    examplesFile = [];
end
if ~exist('saveIn','var') || isempty(saveIn)
    saveIn = pwd;
end

% Get file, and write rst content
newfile = write.filename(title, saveIn);
rst = build.function.rst(title, examplesFile);
write.rst(newfile, rst);

end