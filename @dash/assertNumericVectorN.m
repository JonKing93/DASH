function[] = assertNumericVectorN( input, N, name )
if ~isvector(input) || ~isnumeric(input) || numel(input)~=N
    error('%s must be a numeric vector with %.f elements.', name, N)
end
end