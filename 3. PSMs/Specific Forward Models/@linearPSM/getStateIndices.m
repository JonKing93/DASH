function[] = getStateIndices( obj, ensMeta, varNames, searchParams )
% Gets the state indices required to run a multivariate linear PSM
%
% obj.getStateIndices( ensMeta, varNames )
% Finds the state vector element closest to each listed variable.
%
% obj.getStateIndices( ensMeta, varNames, searchParams )
% Specifies additional search parameters.
%
% ----- Inputs -----
%
% ensMeta: An ensemble metadata object
%
% varNames: The name of the variable associated with each linear slope
%           A cellstring or string vector. (nSlope x 1)
%
% searchParams: Additional search parameters for each variable. A cell
%     vector with one element for each slope. Each element is a cell
%     with formatting: {dim1, meta1, ... dimN, metaN}. When multiple search
%     indices are specified for a single variable, the mean of all
%     associated state elements is used as the variable.
%     See PSM.getClosestLatLonIndex for details on dimN and metaN.
%     
%     *** For Example: 
%           >> varNames = ["SST"; "T"]
%           >> searchParams = { 
%                               {'lev', 1};
%                               {'lev', 100, 'time', ["May";"June";"July] }
%                             }
%
%     would find use the SST element on the level with metadata 1 for
%     the first slope, and the mean of the closest T elements on the level
%     with metadata 100 in May, June, and July for the second slope.

% Set defaults
if ~exist('searchParams','var') || isempty(searchParams)
    searchParams = repmat( {{}}, [numel(obj.slopes), 1] );
end

% Error check
if ~isa( ensMeta, 'ensembleMetadata' ) || ~isscalar(ensMeta)
    error('ensMeta must be a scalar ensembleMetadata object.');
elseif ~isstrlist(varNames)
    error('varNames must be a cellstring or string vector.');
elseif ~iscell(searchParams) || ~isvector(searchParams) || numel(searchParams)~=numel(obj.slopes)
    error('searchParams must be a cell vector with %.f elements.', numel(obj.slopes) );
end
for v = 1:numel(searchParams)
    if ~iscell( searchParams{v} ) || (~isempty(searchParams{v}) && ~isvector(searchParams{v}) )
        error('Element %.f of searchParams is not a cell vector.', v );
    end
end
varNames = string(varNames);

% Initialize values
obj.H = [];
obj.Hlim = NaN( numel(obj.slopes), 2 );

% Get the state indices for each variable
k = 0;
for v = 1:numel(varNames)
    Hvar = ensMeta.closestLatLonIndices( obj.coord, varNames(v), searchParams{v}{:} );
    obj.H = [obj.H; Hvar];
    obj.Hlim(v,:) = k + [1, numel(Hvar)];
    k = k + numel(Hvar);
end

end