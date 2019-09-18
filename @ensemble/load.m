function[M] = load( obj, members, nonan )
%% Loads an ensemble from a .ens file.
%
% M = obj.load
% Returns the entire ensemble.
%
% M = obj.load( members )
% Loads specific ensemble members. Leave empty to load all ensemble members
%
% M = obj.load( members, noNaN )
% Specify whether to prohibit loading ensemble members with NaN values.
% Default is false.
%
% ----- Inputs -----
%
% members: indices specifying which ensemble members to load. Either a vector
%          of linear indices, or a logical vector the length of the ensemble.
%
% noNaN: A scalar logical indicating whether to prohibit loading ensemble
%        members with NaN values. Default is to load all members (false)
%
% ----- Outputs -----
%
% M: The loaded ensemble

% Set defaults
if ~exist('members','var') || isempty(members)
    members = 1:obj.ensSize(2);
end
if ~exist('nonan','var') || isempty(nonan)
    nonan = false;
end

% Error check. use linear indices internally
if ~isscalar(nonan) || ~islogical(nonan)
    error('nonan must be a scalar logical.');
elseif islogical(members) && (~isvector(members) || length(members)~=obj.ensSize(2))
    error('When using logical indices, members must be a vector the length of the ensemble (%.f).', obj.ensSize(2) );
elseif ~isnumeric(member) || ~isreal(members) || ~isvector(members) || any(members<=0) || any(members>obj.ensSize(2)) || any(mod(members,1)~=0)
    error('members must be a vector of positive integers on the closed interval [1, %.f].', obj.ensSize(2) );
end
if islogical(members)
    members = find(members);
end

% Remove NaN members if prohibiting NaN
if nonan
    members( ismember(members, find(obj.hasnan)) ) = [];
end

% If evenly spaced, only load desired values. Otherwise, load the entire range.
[members, order] = sort(members);
loadInterval = members;
spacing = unique( diff( members ) );

if numel(members) > 1 && numel(spacing)>1
    loadInterval = members(1):members(end);
end
keep = ismember( loadInterval, members );

% Load everything, remove undesired members. Reorder members
M = ens.M(:, loadInterval);
M = M(:,keep);
M = M(:, sort(order));       % (Sort indices of sorting indices give reverse sort)

end
