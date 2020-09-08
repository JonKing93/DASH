function[vectorInfo, varInfo] = info(obj, varNames)
%% Returns information about a state vector and its variables
%
% obj.info
% Prints information about the state vector to console
%
% obj.info(v)
% obj.info(varNames)
% Prints information about specific variables in the state vector.
%
% [vectorInfo, varInfo] = obj.info( ... )
% Returns state vector information as a structure and information about
% specified variables as a structure array. Does not print to console.
%
% ----- Inputs -----
%
% varNames: A list of names of variables in the state vector. A string
%    vector or cellstring vector.
%
% v: The indices of variables in the state vector. Either a vector of 
%    linear indices or a logical vector with one element for each variable.
%
% ----- Outputs -----
%
% vectorInfo: A structure containing summary information about the state
%    vector.
%
% varInfo: A structure array containing information on the specified
%    variables in the state vector.

% Default for unset variables
if ~exist('varNames','var') || isempty(varNames)
    varNames = [];
end

% Error check inputs
if dash.isstrlist(varNames)
    v = obj.checkVariables(varNames);
elseif isnumeric(varNames) || islogical(varNames)
    lengthName = 'the number of variables in the state vector';
    v = dash.checkIndices(varNames, 'v', numel(obj.variables), lengthName);
else
    error('The first input must either be list of variable names or indices.');
end

% Summary information
name = obj.name;
title = obj.errorTitle;
title(1) = 'T';
nVars = numel(obj.variables);
vars = obj.variableNames;
nState = 0;
for k = 1:nVars
    nState = nState + prod(obj.variables(k).stateSize);
end
sets = unique(obj.coupled, 'rows');
sets(sum(sets,2)==1, :) = [];
nSets = size(sets,1);
coupledNames = cell(nSets,1);
for s = 1:nSets
    coupledNames{s} = obj.variableNames(sets(s,:));
end

% Structure output
if nargout > 0
    vectorInfo = struct('name', name, 'nVariables', nVars, 'variables', vars, ...
        'nState', nState);
    vectorInfo.coupledVariables = coupledNames;
    
    % Preallocate the variable structure
    nVars = numel(v);
    varInfo = dash.preallocateStructs(stateVectorVariable.infoFields, [nVars, 1]);
    
% Print to console
else
    fprintf('\n%s has a length of %.f.\n', title, nState);
    plural = "variables";
    if nVars==1
        plural = "variable";
    end
    fprintf('It has %.f %s: %s\n', nVars, plural, dash.messageList(vars));
    
    % Coupled variables
    if nSets>0
        plural = ["are", "sets"];
        if nSets == 1
            plural = ["is", "set"];
        end
        fprintf('There %s %.f %s of coupled variables\n', plural(1), nSets, plural(2));
        for s = 1:nSets
            fprintf('\tVariables %s are coupled.\n', dash.messageList(coupledNames{s}));
        end
    end
    fprintf('\n');
end

% Variable information
for k = 1:numel(v)
    if nargout>0
        [varInfo(k), dimInfo] = obj.variables(v(k)).info;
        varInfo(k).dimensions = dimInfo;
    else
        obj.variables(v(k)).info;
        fprintf('\n');
    end
end

end