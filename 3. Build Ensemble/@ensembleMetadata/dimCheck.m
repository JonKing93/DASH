function dims = dimCheck( obj, dims )
% Checks if a set of dimensions are in the ensemble metadata.
% Returns them as a string array.

% Check that dims is either a character row, cellstring, or
% string
if ~isstrlist(dims)
    error('dims must be a character row vector, cellstring, or string array.');
end

% Convert to string for simplicity
dims = string(dims);

% Check that the dims are actually in the ensemble metadata
goodDims = fields( obj.varData );
if any( ~ismember( dims, goodDims ) )
    error('"%s" is not a dimension in the ensemble metadata.', dims( find(~ismember(dims,goodDims),1) ) );
end

end