function[dims] = commaDelimitedDims( dims )
%% Converts a string array of dimension names to a comma delimited
% character row vector.
%
% dims = dashe.commaDelimitedDims( dims )
%
% ----- Inputs -----
%
% dims: A string array of dimension names. A row vector.
%
% ----- Outputs -----
%
% dims: A comma delimited character row vector.

commas = repmat(",", size(dims));
dims = cat(1, dims, commas);
dims = convertStringsToChars( dims(:)' );
dims = cell2mat(dims);
dims(end) = [];

end