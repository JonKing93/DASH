function[X] = loadEnsemble(obj, nEns, grids, sets, settings, progress)
%% Builds a state vector ensemble directly into memory
%
% X = obj.loadEnsemble(nEns, grids, sets, settings, progress)
%
% ----- Inputs -----
%
% nEns: The number of ensemble members to build
%
% grids: A structure containing a cell vector of unique gridfile objects, a
%    cell vector containing the dataSource objects for each gridfile, and 
%    an index vector that maps variables to the correpsonding gridfile
%
% sets: A matrix indicating the sets of coupled variables. Each row is one set.
%
% settings: Load settings for the state vector variables. See svv.loadSettings
%
% progress: A set of progressbar objects for the variables
%
% ----- Outputs -----
%
% X: The loaded state vector ensemble

% Load the variables into memory
try
    nMembers = size(obj.subMembers{1},1);
    members = nMembers-nEns+1:nMembers;
    X = obj.loadVariables(1, nVars, members, grids, sets, settings, progress);
    
% Notify user if too large to fit in memory
catch ME
    if strcmpi(ME.identifier, "DASH:arrayTooBig")
        outputTooBigError();
    end
    rethrow(ME);
end

end

% Long error message
function[] = outputTooBigError()
error(['The state vector ensemble is too large to fit in active memory, so ',...
    'cannot be provided directly as output. Consider saving the ensemble ',...
    'to a .ens file instead.']);
end