function[] = classRST(title, saveIn)

% Default
if ~exist('saveIn','var') || isempty(saveIn)
    saveIn = pwd;
end

% Get new file, write rst content
newfile = write.filename(title, saveIn);
rst = build.class.rst(title);
write.rst(newfile, rst);

end