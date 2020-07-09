function[] = checkSourcesMatchGrid(obj, sources, index)
%% This checks that the size and dataType of specified data sources match
% match the values recorded in the .grid file.

% Get the recorded values
[siz, dataType] = obj.collectPrimitives(["mergedSize","dataType"], index);

% Check the sizes match
for s = 1:numel(sources)
    if any(sources{s}.mergedSize ~= siz{s})
        bad = find(sources{s}.mergedSize ~= siz{s},1);
        error('The size of the %s dimension in %s (%.f) does not match the size recorded in .grid file %s (%.f).', sources{s}.mergedDims(bad), sources{s}.file, sources{s}.mergedSize(bad), obj.file, siz{s}(bad) );
    
    % And also that the data types match
    elseif ~strcmp(sources{s}.dataType, dataType(s))
        error('The data type of the %s variable in file %s (%s), does not match the data type recorded in file %s (%s)', sources{s}.var, sources{s}.file, sources{s}.dataType, obj.file, dataType(s));
    end
end

end