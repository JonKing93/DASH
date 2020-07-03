function[] = info( obj )
%% Returns a summary of a .grid file

% Report the number of defined dimensions.
fprintf('The file:\n%s\nhas %.f dimensions with defined metadata.\n\n', obj.file, sum(obj.isdefined));

% Length of defined dimensions
defined = find(obj.isdefined);
for d = 1:numel(defined)
    fprintf('%s has length %.f\n', obj.dims(defined(d)), obj.size(defined(d)));
end
fprintf('\n');

% Number of sources
[~, name] = fileparts(obj.file);
fprintf('%s manages %.f data sources\n\n', name, numel(obj.source));

% Details of each source

end

