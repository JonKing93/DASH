function[] = packageRST(title, saveIn)
%% Convert a package help file to .rst file

% Default
if ~exist('saveIn','var') || isempty(saveIn)
    saveIn = pwd;
end

% Get the new file, write rst content
newfile = write.filename(title, saveIn);
rst = build.package.rst(title);
write.rst(newfile, rst);

end