function[] = update(obj)
%% Updates the current gridfile object to match an altered .grid file.
%
% obj.update;

% Check that the file still exists
if ~isfile(obj.file)
    error('The file %s no longer exists. It may have been deleted or moved to a new location.', obj.file);
end

% Load the data in the .grid file
m = load(obj.file, '-mat');

% Update the gridfile properties
differentName = ["size", "gridSize"; "meta","metadata"];
fileVariables = fields(m);
props = string(properties('gridfile'));
props(strcmp(props, 'file')) = [];
for p = 1:numel(props)
    
    % Get the name of the file variable associated with the property
    d = find( strcmp(props(p), differentName(:,1)) );
    variable = props(p);
    if ~isempty(d)
        variable = differentName(d,2);
    end
    
    % Check that the variable is in the file
    if ~ismember(variable, fileVariables)
        error('%s does not contain the "%s" field.', obj.file, variable);
    end
    
    % Update the property
    obj.(props(p)) = m.(variable);
end

end