function[] = assertVectorTypeN( input, type, N, name )
%% Checks that an input is a vector with length N. Optionally also checks
% the vector is a specific data type. Returns a customized error message if not.
%
% dash.assertVectorTypeN(input, [], N, name)
% Checks the input is a vector of length N.
% 
% dash.assertVectorTypeN(input, type, N, name)
% Also checks the input is a specific data type.
%
% ----- Inputs -----
%
% input: The input being checked.
%
% type: The required data type. Use [] to only check vector length.
%
% N: The required length of the vector.
%
% name: The name of the input. Used for custom error message.

if ~isvector(input) || numel(input)~=N
    error('%s must be a vector with %.f elements, but it has %.f elements instead.', name, N, numel(input));
end
if ~isempty(type) && ~isa(input, type)
    error('%s must be a %s vector, but it is a %s vector instead.', name, type, class(input));
end

end