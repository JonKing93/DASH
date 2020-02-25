function[F] = useVarsForPSMs( obj, vars, F )
% Only loads state elements needed to run PSMs for specified variables.
%
% obj.useVarsForPSMs( vars, F )
%
% ----- Inputs -----
%
% vars: A list of variables that are only needed to run PSMs. A string,
%       cellstring, or character row vector.
%
% F: A cell array of PSM objects with state indices.
%
% ----- Outputs -----
%
% F: PSMs with updated state indices.

% Error check
if ~isstrlist( vars )
    error('vars must be a string vector, cellstring vector, or character row vector.'
end
v = obj.metadata.varCheck( vars );
if ~iscell(F) || ~isvector(F)
    error('F must be a cell vector');
end

% Cycle through the PSMs. Error check, collect H indices.
nSite = numel(F);
nState = obj.ensSize(1);
psmH = [];
for s = 1:nSite
    if ~isscalar(F{s}) || ~isa(F{s}, 'PSM')
        error('Element %.f of F is not a scalar PSM object.');
    elseif isempty( F{s}.H )
        error('PSM %.f does not have state indices (H)', s );
    end
    H = F{s}.H(:);
    if any(H<1) || any(H>nState) || any(mod(H,1)~=0)
        error('The state indices (H) for PSM %.f are not integers on the interval [1 %.f]', s, nState );
    end
    psmH = [psmH; H]; %#ok<AGROW>
end
  
% Get the set of all H in
allH = (1:nState)';
varH = [];
for k = 1:numel(vars)