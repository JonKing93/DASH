function[dataSources] = review(obj)
% Checks that data sources are valid, returns a cell vector of pre-built
% sources

% Update and preallocate
obj.update;
dataSources = cell(obj.nSource, 1);

% Build each source
for s = 1:obj.nSource
    try
        dataSources{s} = obj.sources.build(s);
    catch ME
        dataSourceFailedError(ME);
    end
    
    % Check the data in the source matches the size and data type recorded
    % in the gridfile
    obj.sources.assertMatch(s, dataSources{s});
end

end
    