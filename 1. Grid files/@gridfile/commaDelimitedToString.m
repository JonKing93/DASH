function[dims] = commaDelimitedToString( dims )
%% Converts a comma delimited string scalar or character row vector to a
% a string array.
%
% dims = gridfile.commaDelimitedToString( dims )
%
% ----- Inputs -----
%
% dims: Comma delimited string scalar or character row vector.
%
% ----- Outputs -----
%
% dims: String array

dims = char(dims);
dims = textscan(dims, '%s', 'Delimiter', ',');
dims = string(dims{:}');

end