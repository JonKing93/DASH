function[] = tests

constructor;
add;
remove;
indices;
unpack;
info;
build;
ismatch;
absolutePaths;
savePath;

end

function[] = constructor
try
    dash.gridfileSources;
catch
    error('constructor');
end
end