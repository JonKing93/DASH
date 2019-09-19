function[] = dimCheck(ensMeta, dim)
%% Checks that a dimension is in the ensemble metadata

if ~ismember( dim, fields(ensMeta.stateMeta.(ensMeta.varName(1)) )
    error('%s is not a dimension in the ensemble metadata.', dim);
end

end