function[] = assertNumericVectorN( input, N, name )
%% Checks that an input is a numeric vector with length N. Returns a
% customized error message if not.
%
% dash.assertNumericVectorN(input, N, name)
%
% ----- Inputs -----
%
% input: The input being checked
%
% N: The required length of the vector.
%
% name: The name of the input. Used for custom error message.

if ~isvector(input) || ~isnumeric(input) || numel(input)~=N
    error('%s must be a numeric vector with %.f elements.', name, N)
end

end