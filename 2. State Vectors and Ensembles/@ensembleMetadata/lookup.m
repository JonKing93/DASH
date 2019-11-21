function[meta] = lookup( obj, dims, inArg )
% Returns ensemble metadata at specific indices and dimensions.
%
% meta = obj.lookup( dims, H )
% Returns the metadata along specified dimensions at state indices 'H'.
%
% meta = obj.lookup( dims, varName )
% Returns the metadata along specified dimensions at all indices for
% the specified variable.
%
% ***Note: H and varName may not reference more than 1
% variable.
%
% ----- Inputs -----
%
% dims: A set of dimension names. Either a single character
%       vector, cellstring, or string array,.
%
% H: A vector of indices in the state vector. May not contain
% indices for more than 1 variable.
%
% varName: The name of a variable.
% 
% ----- Outputs -----
%
% meta: 
%   If a single dimension is specified, a matrix of metadata. 
%   Each row corresponds to a specific index.
%
%   If multiple dimensions are specified, returns a structure.
%   The fields of the structure are the metadata matrices for
%   each queried dimension.

% If the input is a variable name, just get the indices
if isstrflag( inArg)   
    v = obj.varCheck( inArg );
    H = obj.varIndices( inArg );
    
% But don't allow multiple variable names
elseif isstrlist( inArg )
    error('varName can only refer to a single variable.');
    
% Assume anything else is a set of indices. Error check
else                               
    H = inArg;
    if ~isvector(inArg) || ~isnumeric(inArg) || any(inArg < 1) || any(mod(inArg,1)~=0)
        error('H indices must be a numeric vector of positive integers.');
    elseif any( H > obj.varLimit(end,2) )
        error('H contains indices longer than the state vector.');
    end
    H = H(:);
    
    % Then get the associated variables and ensure there is only 1
    [v, ~] =  find(  H' >= obj.varLimit(:,1)  &  H' <= obj.varLimit(:,2)  );
    v = unique(v);
    if numel(v)~=1
        error('H cannot reference more than a single variable.');
    end
end
dims = obj.dimCheck( dims );

% Adjust indices to just the variable and get ND subscript indices
H = H - obj.varLimit(v,1) + 1;
subDex = subdim( H, obj.varSize(v,:) );

% Get the metadata structure at each index for each dimension. If there's
% only a single dimension, just return the array
meta = struct();
for d = 1:numel(dims)
    col = find( ismember(obj.design.var(v).dimID, dims(d)) );
    meta.(dims(d)) = obj.stateMeta.(obj.varName(v)).(dims(d))( subDex(:,col), :, : );
end
if numel(dims) == 1
    meta = meta.(dims);
end

end