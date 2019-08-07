function[obj] = stateDimension( obj, v, d, varargin )
% v: Variable index in state Design
%
% d: Dimension index in varDesign

% Parse inputs. Use the pre-existing values as the defaults. (This way a
% second call to obj.edit, as may happen in the console, doesn't overwrite)
[index, takeMean, nanflag] = parseInputs( varargin, {'index', 'mean', 'nanflag'}, ...
    {obj.var(v).indices{d}, obj.var(v).takeMean(d), obj.var(v).nanflag{d}} );

% Error check and set takeMean and the nanflag
obj.var(v).takeMean(d) = errCheck(takeMean);
obj.var(v).nanflag{d} = obj.getNaNflag( v, d, nanflag, varargin(1:2:end-1) );

 % Error check, process, and record indices. (Sorted column, linear)
obj.var(v).indices{d} = obj.checkIndices( index, v, d );

% For each coupled variable (including the specified variable)
v = find( obj.isCoupled(v,:) );
for k = 1:numel(v)
    
    % If changing dimension type, delete sequence and mean data. Notify the user
    if ~obj.var(v(k)).isState(d)
        obj.var(v(k)).isState(d) = true;

        obj.var(v(k)).takeMean(dim) = false;
        obj.var(v(k)).meanDex{dim} = [];
        obj.var(v(k)).nanflag{dim} = [];
        obj.var(v(k)).seqDex{dim} = [];
        obj.var(v(k)).seqMeta{dim} = [];
        
        obj.notifyChangedType( v(k), d, true );
    end
end

end

function[takeMean] = errCheck(takeMean)
    if ~isscalar(takeMean) || ~islogical(takeMean)
        error('takeMean must be a scalar logical.');
    end
end

