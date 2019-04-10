function[design] = coupleIndices( design )

% Get the sets of coupled variables
coupVars = getCoupledVars( design.isCoupled );

% Trim the ensemble indices for each variable to only allow complete sequences
for v = 1:numel(design.var)
    design.var(v) = trimEnsembleDims( design.var(v) );
end

% Restrict each set of coupled variables to matching metadata
for cv = 1:numel(coupVars)
    design = matchCoupledMeta( design, coupVars{cv} );
end

end