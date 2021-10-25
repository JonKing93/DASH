function[links] = packageContents(subfolder, files)

nFiles = numel(files);
links = strings(nFiles, 1);

for f = 1:nFiles
    links(f) = sprintf("%s/%s", subfolder, files(f));
end

end