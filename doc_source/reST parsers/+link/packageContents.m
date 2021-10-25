function[links] = packageContents(subfolder, files)

nSections = numel(files);
links = cell(nSections, 1);

for s = 1:nSections
    nFiles = numel(files{s});
    links{s} = strings(nFiles, 1);
    for f = 1:nFiles
        links{s}(f) = sprintf("%s/%s", subfolder, files{s}(f));
    end
end

end