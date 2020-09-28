function[obj] = append(obj, meta2)
%% Appends the metadata for a second state vector ensemble to the end of
% the current ensemble metadata.
%
% obj = obj.append(meta2)
%
% ----- Inputs -----
%
% meta2: A second ensembleMetadata object. May not duplicate names of any
%    variables in the current ensemble metadata.
%
% ----- Outputs -----
%
% obj: The updated ensembleMetadata object

% Error check
if ~isa(meta2, 'ensembleMetadata')
    error('meta2 must be an ensembleMetadata object.');
elseif ~isscalar(meta2)
    error('meta2 must be a scalar ensembleMetadata object.');
end

% Check for naming conflicts and same ensemble size
[ismem, k] = ismember(obj.variableNames, meta2.variableNames);
if any(ismem)
    error('Both the current ensemble metadata and the metadata being appended have a variable named "%s".', obj.variableNames(find(k,1)));
end

% Require the same ensemble size
if obj.nEns ~= meta2.nEns
    error('The current ensemble metadata has %.f ensemble members, but the metadata being appended has %.f instead.', obj.nEns, meta2.nEns);
end

% Append fields
fields = ["variableNames","varLimit","nEls","dims","stateSize","isState"];
for f = 1:numel(fields)
    obj.(fields(f)) = [obj.(fields(f)); meta2.(fields(f))];
end

% Append metadata
for v = 1:numel(meta2.variableNames)
    varName = meta2.variableNames(v);
    obj.metadata.(varName) = meta2.metadata.(varName);
end

end