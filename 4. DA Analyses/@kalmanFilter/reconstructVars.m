function[] = reconstructVars( obj, vars )
% Specifies which variables or state vector elements to reconstruct.
%
% obj.reconstructVars( vars )
% Specify which variables to reconstruct. Requires M to be an ensemble
% object. By default, all variables are reconstructed.
%
% obj.reconstructVars
% Returns filter to default and reconstructs all variables.
%
% ----- Inputs -----
%
% vars: A list of variable names. A string array, cellstring, or character
%       row vector.

% Error check
if ~isa( obj.M, 'ensemble' )
    error('M must be an ensemble object.');
elseif ~isstrlist(vars)
    error('vars must be a string, cellstring, or character row vector.');
end
obj.M.metadata.varCheck(vars);
vars = string(vars);

% Get the variable indices to reconstruct
reconIndex = [];
for v = 1:numel(vars)
    reconIndex = [reconIndex; obj.M.metadata.varIndices( vars(v) )]; %#ok<AGROW>
end

% Get the PSM indices needed
psmIndex = [];
for s = 1:numel( obj.F )
    psmIndex = [psmIndex; obj.F{s}.H]; %#ok<AGROW>
end
psmIndex = unique( psmIndex );

% If serial updates, ensure that all of the psm elements will be
% reconstructed
if strcmpi(obj.type, 'serial') && any( ~ismember(psmIndex, reconIndex) )
    error('When using serial updates, you must reconstruct every variable used to run the PSMs.');
end

% Save
obj.reconVars = vars;
obj.reconIndex = reconIndex;
obj.psmIndex = psmIndex;

end