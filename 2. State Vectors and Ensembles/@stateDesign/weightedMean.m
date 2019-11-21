function[obj] = weightedMean( obj, var, dims, weights, nanflag )
%% Specifies weights to use when taking a mean.
%
% design = obj.weightedMean( var, dims, weights )
% Uses a weighted mean for specified dimensions of a particular variable.
%
% design = obj.weightedMean( var, dims, weights, nanflag )
% Indicates how to treat NaN values in a mean. Default is to include nan.
%
% ----- Inputs -----
%
% var: The name of a variable. A string.
%
% dims: The dimensions over which to apply the weighted mean. A string
%       vector.
%
% weights: The weights to apply. For dims = ["dim1", "dim2", ... "dimN"],
%          this is an array of size [length(dim1), length(dim2), ... length(dimN)].
%
% nanflag: A string scalar indicating whether to include NaN values
%           "includenan": Use NaN values when computing a mean
%           "omitnan": Remove NaN values when computing a mean
%
% ----- Outputs -----
%
% design: The updated stateDesign object.

% Set defaults. Get indices
if ~exist('nanflag','var') || isempty(nanflag)
    nanflag = "includenan";
end
v = obj.findVarIndices( var );
dims = obj.findDimIndices( v, dims );

% Error check
[~,dimSize] = obj.varIndices;
dimSize = dimSize(v,:);
if ~isstrflag(var)
    error('var must be a string scalar or character row vector.');
elseif ~isstrflag(nanflag) || ~ismember(nanflag, ["includenan","omitnan"])
    error('nanflag must either be "includenan" or "omitnan".');
elseif ~isnumeric(weights) || ~isreal(weights)
    error('Weights must be a numeric, real array.');
elseif ~isequal(  size(weights),  dimSize(dims) )
    errString = ['[', sprintf('%.f x ', dimSize(dims)), sprintf('\b\b\b]')];
    error('The size of the weights array must match the length of each dimension in the state vector: %s.', errString);
elseif ~isempty( obj.var(v).weightDims ) && any( obj.var(v).weightDims(:,dims), 'all' )
    [~, dim] = find( obj.var(v).weightDims(:,dims) );
    error(['The dimensions ', sprintf('"%s", ', obj.var(v).dimID(dim)), 'are already being used in weighted means.']);
end



% Permute the weights to match the order of dimensions in the grid file
[dims, reorder] = sort( dims );
weights = permute( weights, reorder );
resize = ones( 1, numel(obj.var(v).dimID) );
resize(dims) = size(weights);
weights = reshape( weights, resize );

% Set takeMean and nanflag for all relevant dimensions
for d = 1:numel(dims)
    obj.var(v).takeMean( dims(d) ) = true;
    obj.var(v).nanflag{ dims(d) } = nanflag;
end 

% Record the weights
newDims = false( 1, numel(obj.var(v).dimID) );
newDims( dims ) = true;
obj.var(v).weightDims(end+1,:) = newDims;

obj.var(v).weights = cat(1, obj.var(v).weights, {weights} );

end