function[] = reconstructVars( obj, vars, ensMeta )
% Specifies to only reconstruct certain variables.
%
% obj.reconstructVars( vars, ensMeta )
% Reconstructs specific variables given the ensemble metadata for the
% prior.
%
% ----- Inputs -----
%
% vars: The names of the variables to reconstruct.
%
% ensMeta: The ensemble metadata for the prior.

% Error check
if ~isscalar(ensMeta) || ~isa(ensMeta, 'ensembleMetadata')
    error('ensMeta must be a scalar ensembleMetadata object.');
end
ensMeta.varCheck( vars );
vars = string(vars);

% Check that this ensemble metadata matches the size of M
if isa(obj.M, 'ensemble')
    Mmeta = obj.M.loadMetadata;
    nState = Mmeta.ensSize(1);
else
    nState = size(M,1);
end
if ensMeta.ensSize(1)~=nState
    error('The ensemble metadata does not match the number of state elements (%.f) in the prior.', nState );
end

% Get the indices to reconstruct
nVars = numel(vars);
indices = cell( nVars, 1 );
for v = 1:nVars
    indices{v} = ensMeta.varIndices( vars(v) );
end
indices = cell2mat( indices );

% Convert to logical
reconstruct = false( nState, 1 );
reconstruct( indices ) = true;

% Check if PSM H indices are reconstructed. Throw error for serial
reconH = dash.checkReconH( reconstruct, obj.F );
if ~reconH && strcmpi(obj.type,'serial') && ~obj.append
    error('When using serial updates without appended Ye, you must reconstruct all state elements used to run the PSMs.');
end

% Set the values
obj.reconstruct = reconstruct;
obj.reconH = reconH;

end