function[X, meta, obj] = buildEnsemble(obj, nEns, grids, ens, showprogress)
%% Builds a state vector ensemble.
%
% [X, meta, obj] = obj.buildEnsemble(nEns, grids, [], showprogress)
% Builds a state vector ensemble and returns it as an array.
%
% [~, meta, obj] = obj.buildEnsemble(nEns, grids, ens, showprogress)
% Builds a state vector ensemble and writes it to a .ens file.
%
% ----- Inputs -----
%
% nEns: The number of ensemble members to build.
%
% grids: A structure containing
%   grids: a cell vector of unique gridfile objects
%   sources: a cell vector containing the dataSource objects for each gridfile
%   f: an index vector that maps variables to the correpsonding gridfile
%
% ens: A matfile object for a .ens file.
%
% showprogress: Scalar logical indicating whether to display progress bar
%    (true -- default), or not (false).
% 
% ----- Outputs -----
%
% X: The state vector ensemble. A numeric matrix (nState x nEns)
%
% meta: An ensembleMetadata object for the ensemble.
%
% obj: A stateVector object associated with the ensemble.

% Cycle through the sets of coupled variables to select ensemble members.
sets = unique(obj.coupled, 'rows');
for s = 1:size(sets,1)
    v = find(sets(s,:));
    var1 = obj.variables(v(1));

    % Initialize a set of subscripted ensemble members
    nDims = numel(obj.dims{s});
    subMembers = NaN(nEns, nDims);
    subIndexCell = cell(1, nDims);
    siz = var1.ensSize(~var1.isState);
    
    % Select ensemble members and optionally remove overlapping members
    % until the ensemble is complete.
    nNeeded = nEns;
    unused = obj.unused{s};
    while nNeeded > 0
        if nNeeded > numel(unused)
            notEnoughMembersError(obj.variableNames(v), obj.overlap(v), nEns);
        end

        % Select members. Remove values from the unused members when selected
        members = unused(1:nNeeded);
        unused(1:nNeeded,:) = [];

        % Get the subscript indices of ensemble members
        [subIndexCell{:}] = ind2sub(siz, members);
        subMembers(nEns-nNeeded+1:nEns, :) = cell2mat(subIndexCell);

        % Optionally remove ensemble members with overlapping data. Update
        % the number of ensemble members needed
        for k = 1:numel(v)
            if ~obj.overlap(v(k))
                subMembers = obj.variables(v(k)).removeOverlap(subMembers, obj.dims{s});
            end
        end
        nNeeded = nEns - size(subMembers, 1);
    end

    % Update the subscripted ensemble members and unused members
    obj.subMembers{s} = [obj.subMembers{s}; subMembers];
    obj.unused{s} = unused;
end

% Get the set index for each variable
[sets, ~] = find(sets);

% Preallocate load settings for each variable
nVars = numel(obj.variables);
settings = dash.struct.preallocate(stateVectorVariable.loadSettingFields, [nVars, 1]);

% Get load settings, and check that single ensemble members can fit in memory
for v = 1:nVars
    settings(v) = obj.variables(v).loadSettings(obj.dims{sets(v)});    
    try
        NaN([settings(v).siz, 1]);
    catch
        tooBigError(obj.variables(v).name);
    end
end

% Initialize progress bars
progress = cell(nVars, 1);
step = ceil(nEns/100);
for v = 1:nVars
    message = sprintf('Building "%s":', obj.variables(v).name);
    progress{v} = dash.misc.progressbar(showprogress, message, nEns, step);
end

% Either load the array directly or write to file
meta = ensembleMetadata(obj);
if isempty(ens)
    X = obj.loadEnsemble(nEns, grids, sets, settings, progress);
else
    obj.writeEnsemble(nEns, grids, sets, settings, ens, progress);
    X = [];
    ens.metadata = meta.convertToPrimitives;
    ens.stateVector = obj.convertToPrimitives;
end

end

% Long error message
function[] = notEnoughMembersError(varNames, overlap, nEns)
if numel(varNames) == 1
    str1 = "non-overlapping";
    str3 = 'or allowing overlap';
    if overlap
        str1 = sprintf('\b');
        str3 = sprintf('\b');
    end
    str2 = sprintf('variable "%s"', varNames);
else
    str1 = sprintf('\b');
    str2 = sprintf('couple variables %s', dash.string.messageList(varNames));
    if sum(~overlap)==1
        str2 = strcat(str2, sprintf(' with no overlap for variable "%s"', varNames(overlap)));
    elseif sum(~overlap)>1
        str2 = strcat(str2, sprintf(' with no overlap in variables %s', dash.string.messageList(varNames(overlap))));
    end
    str3 = '.';
    if any(~overlap)
        str3 = 'or allowing overlap';
    end
end
error(['Cannot find %.f %s ensemble members for %s. Consider using fewer ', ...
    'ensemble members %s.'], nEns, str1, str2, str3);
end
function[] = tooBigError(name)
error(['The "%s" variable has so many state elements that even a single ',...
    'ensemble member cannot fit in memory. Consider reducing the size of ',...
    '"%s".'], name, name);
end