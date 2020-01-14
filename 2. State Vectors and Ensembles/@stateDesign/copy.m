function[obj] = copy( obj, fromVar, toVars )
%% Copies design specifications from a template variable to a set of other variables.
% ***Note: The variables will NOT be coupled.
%
% design = obj.copy( fromVar, toVars )
% Copies design specifications from a variable to other variables. Copied
% state and ensemble indices are set via metadata matching and NOT as a
% direct copy of linear indices.
%
% ----- Inputs -----
%
% obj: A state vector design
%
% fromVar: The template variable. A string scalar.
%
% toVars: The variables into which indices will be copied. Either a
%         character row vector, cellstring, or string vector.
%
% ----- Outputs -----
%
% design: The updated state vector design

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the template variable and copying variables
tv = obj.findVarIndices( fromVar );
v = obj.findVarIndices( toVars );

% Only allow a single template variable. Get a quick reference to make the
% code readable
if numel(tv) > 1
    error('fromVar must be a string scalar.');
end
tvar = obj.var(tv);

% For each dimension
for d = 1:numel(tvar.dimID)
    
    % Get the indexed metadata for the template variable
    meta = tvar.meta.(tvar.dimID(d))( tvar.indices{d},: );
    
    % For each copying variable
    for k = 1:numel(v)
        var = obj.var(v(k));
        
        % Get the indices with matching metadata. If both have NaN
        % metadata, then this is a singleton dimension with index 1.
        currMeta = var.meta.(tvar.dimID(d));
        index = 1;
        if ~(isscalar(currMeta) && isnan(currMeta)) || ~(isscalar(meta) && isnan(meta))
            [~, index] = intersect( currMeta, meta, 'rows', 'stable' );
        end
        
        % Edit state dimensions. Must have the same number of state indices
        if tvar.isState(d)
            if numel(index) ~= size(meta,1)
                error('The %s variable does not have metadata matching all state indices of the template %s variable in the %s dimension.', var.name, tvar.name, tvar.dimID(d));
            end
            obj = obj.stateDimension( v(k), d, 'index', index, 'mean', tvar.takeMean(d), 'nanflag', tvar.nanflag{d} );
            
            
        % Edit ensemble dimension. Must have some ensemble indices.
        else
            if isempty(index)
                error('The %s variable does not have metadata matching any of the metadata for the template variable %s in the %s dimension.', var.name, tvar.name, tvar.dimID(d) );
            end
            obj = obj.ensDimension( v(k), d, 'index', index, 'seq', tvar.seqDex{d}, 'meta', tvar.seqMeta{d}, 'mean', tvar.meanDex{d}, 'nanflag', tvar.nanflag{d} );
        end
        
        % Set overlap permissions
        if d == 1
            obj.allowOverlap(v(k)) = obj.allowOverlap(tv);
        end
    end
end

end       