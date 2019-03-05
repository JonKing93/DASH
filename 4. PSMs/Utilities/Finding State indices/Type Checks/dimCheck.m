function[] = dimCheck(ensMeta, field)

if ~isfield(ensMeta, field)
    error('%s must be a field in the ensemble metadata.', field);
end

end