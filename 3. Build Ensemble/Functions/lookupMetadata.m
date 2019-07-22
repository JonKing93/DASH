function[meta] = lookupMetadata( ensMeta, H, dim )
%% Returns the ensemble metadata at the specified state indices for a
% particular dimenion.
%
% meta = lookupMetadata( ensMeta, H, dim )
% Returns the metadata for a dimension "dim" at state indices "H"
%
% meta = lookupMetadata( ensMeta, varName, dim )
% Returns all the metadata for a variable along dimension "dim".
% 
% ----- Inputs -----
%
% ensMeta: An ensemble metadata structure.
%
% H: A set of state indices. Must be a vector.
%
% dim: A dimension ID
%
% varName: A variable name
%
% ----- Outputs -----
%
% meta: The metadata array at the specified indices for dimension "dim"

% ----- Written By -----
% Jonathan King, University of Arizona,  2019

% Initial error checking
dimCheck(ensMeta, dim);
if ~isstruct(ensMeta) || ~isfield(ensMeta, 'var') || ~isfield(ensMeta, 'varLim')
    error('The ensemble metadata is missing fields.');
elseif ~isfield(ensMeta.var, dim)
    error('There is no %s dimension in the ensemble metadata.', dim );
end

% If a string input for variable name
if isstrflag(H)
    
    % Get the variable index
    v = varCheck( ensMeta, H );
    
    % Get all the state indices
    H = getVarStateIndex(ensMeta, H)';

% Otherwise, if a set of indices
else
    
    % Error check the indices
    if ~isvector(H) || ~isnumeric(H)
        error('H must be a numeric vector.');
    elseif any( mod(H,1)~=0 )
        error('H can only contain integers.');
    elseif any( H<0 | H>ensMeta.varLim(end) )
        error('H cannot contain indices outside the interval [1, %0.f]', ensMeta.varLim(end) );
    end
    
    % Convert H to a row vector
    H = H(:)';
    
    % Get the variable being indexed by each state index
    [v, ~] =  find(  H >= ensMeta.varLim(:,1)  &  H <= ensMeta.varLim(:,2)  );
    v = unique(v);

    % Ensure that only one variable is indexed
    if numel(v) > 1
        error('Can only lookup metadata for a single variable at a time. Currently, 2+ variables are indexed.');
    end
end

% Adjust the H indices so they are 1 indexed to the start of the variable
H = H - ensMeta.varLim(v,1) + 1;

% Get the N-dimensional subscript indices
subDex = subdim( ensMeta.varSize(v,:), H' );

% Get the particular dimension of interest
d = strcmp( fields(ensMeta.var), dim );

% Get the metadata
meta = ensMeta.var(v).(dim)( subDex(:,d) );

end
