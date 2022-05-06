function[] = packageRST(title, saveIn)
%% write.packageRST  Builds a RST file from the help text in the Contents.m file of a package.
% ----------
%   write.packageRST(title, saveIn)
%   Loads the help text for a package from its Contents.m file, formats the
%   help text into RST, and writes the RST file.
% ----------
%   Inputs:
%       title (string scalar): The dot-indexing title of the package
%       saveIn (string scalar): The absolute path to the folder in which to
%           save the RST file.

% Default
if ~exist('saveIn','var') || isempty(saveIn)
    saveIn = pwd;
end

% Get the new file, write rst content
newfile = write.filename(title, saveIn);
rst = build.package.rst(title);
write.rst(newfile, rst);

end