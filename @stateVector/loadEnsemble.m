function[X] = loadEnsemble(obj, nEns, g, sets, settings, showprogress)

% Initialize progress bars
nVars = numel(obj.variables);
progress = cell(nVars, 1);
step = ceil(nEns/100);
for v = 1:nVars
    message = sprintf('Building "%s":', obj.variables(v).name);
    progress{v} = progressbar(showprogress, message, nEns, step);
end

% Load the variables into memory
try
    nMembers = size(obj.subMembers{1},1);
    members = nMembers-nEns+1:nMembers;
    X = obj.loadVariables(1, nVars, members, g, sets, settings, progress);
    
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