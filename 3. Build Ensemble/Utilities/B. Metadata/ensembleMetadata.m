function[meta] = ensembleMetadata( design )
%% Generates the ensemble metadata for an ensemble.
%
% meta = ensembleMetadata( design )
%
% ----- Inputs -----
%
% design: A state vector design
%
% ----- Outputs -----
%
% meta: The metadata structure for an ensemble built from the state vector
%       design.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the state indices associated with each variable
[varLim, varSize, nEls] = getVarIndices( design.var );

% Record the index limits for each variable as well as variable names
meta.varName = design.varName;
meta.varLim = varLim;
meta.varSize = varSize;
meta.nEls = nEls;

% For each variable
for v = 1:numel(design.var)
    var = design.var(v);

    % For each dimension
    for d = 1:numel(var.dimID)
        
        % If a state dimension, get the metadata by querying the grid
        % metadata at the state indices
        if var.isState(d)
            dimMeta = var.meta.(var.dimID(d))( var.indices{d}, : );
            
            % If the state dimension is taking a mean, propagate the
            % multiple sets of metadata down the third dimension.
            if var.takeMean(d)
                dimMeta = permute(dimMeta, [3 2 1]);
            end
            
        % Otherwise, if this is an ensemble dimension, the dimensional
        % metadata is the entire set of sequence metadata
        else
            dimMeta = var.seqMeta{d};
        end
        
        % So, we now have the set of metadata restricted to the useful
        % indices for the dimension. Save this to the metadata structure
        meta.var(v,1).(var.dimID(d)) = dimMeta;
    end
end

end