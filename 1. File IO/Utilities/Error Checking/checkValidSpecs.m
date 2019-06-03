function[] = checkValidSpecs( specs )

% Scalar structure
if ~isstruct(specs) || ~isscalar(specs)
    error('The variable ''specs'' must be a scalar structure (struct).');
end

% Check that each field of specs is a NetCDF4 type
specNames = string( fieldnames( specs ) );
for s = 1:numel(specNames)
    if ~isnctype( specs.(specNames(s)) )
        error('The "%s" attribute in the "specs" structure contains data that is not a valid NetCDF4 type.', specNames(s) );
    end
end

end