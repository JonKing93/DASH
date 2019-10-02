function[obj] = stateDimension( obj, v, d, varargin )
% Internal function for editing state dimensions
% v: Variable index in state Design
%
% d: Dimension index in varDesign

% Parse inputs. Use the pre-existing values as the defaults. (This way a
% second call to obj.edit, as may happen in the console, doesn't overwrite)
[index, takeMean, nanflag] = parseInputs( varargin, {'index', 'mean', 'nanflag'}, ...
    {obj.var(v).indices{d}, obj.var(v).takeMean(d), obj.var(v).nanflag{d}}, {[],[],[]});

% Error check and set takeMean and the nanflag
obj.var(v).takeMean(d) = errCheck(takeMean);
obj.var(v).nanflag{d} = obj.getNaNflag( v, d, nanflag, varargin(1:2:end-1) );

 % Error check, process, and record indices. (Sorted column, linear)
obj.var(v).indices{d} = obj.checkIndices( index, v, d );

% If changing dimension type, change for all coupled variables
% Delete coupled sequence and mean, notify user.
if ~obj.var(v).isState(d)
    obj = obj.changeDimType( v, d );
end

end

function[takeMean] = errCheck(takeMean)
    if ~isscalar(takeMean) || ~islogical(takeMean)
        error('takeMean must be a scalar logical.');
    end
end

