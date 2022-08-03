function[newfile] = filename(title, saveIn)
%% write.filename  Determines the absolute path to the RST file
% ----------
%   newfile = write.filename(title, saveIn)
%   Determines the absolute path to a RST file based on the dot-indexing
%   title of a content item and a containing folder.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing name of an item
%       saveIn (string scalar): The absolute path to the folder that
%           should hold the RST file.
%
%   Outputs:
%       newfile (string scalar): The absolute path to the RST file

name = parse.name(title, true);
newfile = [saveIn, filesep, char(name), '.rst'];

end