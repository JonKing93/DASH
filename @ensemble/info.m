function[s] = info(obj)
%% Returns information about an ensemble object.
%
% obj.info
% Prints information to the console.
%
% s = obj.info;
% Returns information as a structure.
%
% ----- Outputs -----
%
% s: A structure whose fields contain information on an ensemble object.

% Update
obj.update;

% Get the information about the file data
nState = obj.meta.varLimit(end);
nEns = obj.meta.nEns;

% Get info about the loaded data
[members, v] = obj.loadSettings;
nStateLoad = sum(obj.meta.nEls(v));
nEnsLoad = numel(members);

% Print to console if no outputs
if nargout==0
    fprintf('\n');
    fprintf('This ensemble object manages data in file "%s".\n', obj.file);
    fprintf('The data in the file has a state vector length of %.f and %.f ensemble members.\n', nState, nEns);
    
    if isequal(v(:), (1:numel(obj.meta.variableNames))')
        fprintf('This ensemble object will load data for all variables.\n');
    else
        fprintf('This object will load data for variables: %s.\n', dash.messageList(obj.variables));
    end
    fprintf('The loaded data will have a state vector length of %.f and %.f ensemble members.\n\n', nStateLoad, nEnsLoad);
    
% Otherwise, return a structure
else
    s = struct('file', obj.file, 'sizeInFile', [nState, nEns], ...
        'loadVariables', obj.variables, 'loadMembers', members, 'sizeOnLoad', [nStateLoad, nEnsLoad]);
end

end