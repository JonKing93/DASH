function[X, meta, obj] = buildEnsemble(obj, nEns, grids, ens, showprogress)
%% Builds a state vector ensemble.
%
% [X, meta, obj] = obj.buildEnsemble(nEns, grids, [], showprogress)
% Builds a state vector ensemble and returns it as an array.
%
% [~, meta, obj] = obj.buildEnsemble(nEns, grids, showprogress)
% Builds a state vector ensemble and writes it to a .ens file.
%
% ----- Inputs -----
%
% nEns: The number of ensemble members to build.
%
% grids: A prebuiltGrids object
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

% Either load the array directly or write to file
if isempty(ens)
    X = obj.loadEnsemble(nEns, grids, showprogress);
else
    obj.writeEnsemble(nEns, grids, ens, showprogress);
    X = [];
end

% Get the metadata for the ensemble
%
%
%

end













% Note if writing to file
writeFile = false;
if ~isempty(ens)
    writeFile = true;
end

% Get sizes
nVars = numel(obj.variables);
varLimit = obj.variableLimits;
nState = varLimit(end, 2);

% Preallocate output array.
X = [];
if ~writeFile
    try
        X = NaN(nState, nEns);
    catch
        outputTooBigError();
    end
    
% Or preallocate space in the .ens file
else
    [~, nCols] = size(ens, 'X');
    ens.X(nState, nCols+nEns) = NaN;
    ens.hasnan(nVars, nCols+nEns) = false;
end

% Get the state vector rows and coupling set for each variable. Collect the
% inputs for svv.buildEnsemble
for v = 1:nVars
    rows = varLimit(v,1):varLimit(v,2);
    s = find( sets(:,v) );
    inputs = {obj.subMembers{s}(end-nEns+1:end, :), obj.dims{s}, grids{f(v)},...
        sources{f(v)}, [], [], showprogress};

    % Build the ensemble for the variable. Get array or save to file
    if writeFile
        inputs(5:6) = {ens, rows};
        ens.hasnan(v,nCols+(1:nEns)) = obj.variables(v).buildEnsemble( inputs{:} );
    else
        X(rows,:) = obj.variables(v).buildEnsemble( inputs{:} ); %#ok<AGROW>
    end
end

% Ensemble metadata
meta = ensembleMetadata(obj);
if writeFile
    ens.metadata = meta;
    ens.stateVector = obj;
end

end

% Long error messages
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
    str2 = sprintf('couple variables %s', dash.messageList(varNames));
    if sum(~overlap)==1
        str2 = strcat(str2, sprintf(' with no overlap for variable "%s"', varNames(overlap)));
    elseif sum(~overlap)>1
        str2 = strcat(str2, sprintf(' with no overlap in variables %s', dash.messageList(varNames(overlap))));
    end
    str3 = '.';
    if any(~overlap)
        str3 = 'or allowing overlap';
    end
end
error(['Cannot find %.f %s ensemble members for %s. Consider using fewer ', ...
    'ensemble members %s.'], nEns, str1, str2, str3);
end
