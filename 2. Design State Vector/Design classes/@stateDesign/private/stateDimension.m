function[obj] = stateDimension( obj, v, d, varargin )
% v: Variable index in state Design
%
% d: Dimension index in varDesign

% Parse inputs. Use the pre-existing values as the defaults. (This way a
% second call to obj.edit, as may happen in the console, doesn't overwrite)
[index, takeMean, nanflag] = parseInputs( varargin, {'index', 'mean', 'nanflag'}, ...
    {obj.var(v).indices{d}, obj.var(v).takeMean(d), obj.var(v).nanflag{d}} );

% Error check and set the non-index inputs.
errCheck( takeMean, nanflag );
obj.var(v).takeMean(d) = takeMean;
obj.var(v).nanflag{d} = nanflag;

 % Error check, process, and record indices. (Sorted column, linear)
obj.var(v).indices{d} = obj.checkIndices( index, v, d );

% For each coupled variable (including the specified variable)
v = find( obj.isCoupled(v,:) );
for k = 1:numel(v)
    
    % Mark the dimension as a state dimension
    obj.var(v(k)).isState(d) = true;
    
    % Remove the nanflag if it referred to an ensemble mean
    if ~isempty( obj.var(v).meanDex{d} )
        obj.var(v).nanflag = [];
    end

    % Delete ensemble dimension properties
    obj.var(v).seqDex{d} = [];
    obj.var(v).meanDex{d} = [];
    obj.var(v).seqMeta{d} = [];
    obj.var(v).overlap = [];
end

end

function[] = errCheck( takeMean, nanflag )
if ~isscalar(takeMean) || ~islogical(takeMean)
    error('takeMean must be a scalar logical.');
elseif ~strflag(nanflag) || ~ismember(nanflag, ["omitnan","includenan"])
    error('nanflag must be either "omitnan" or "includenan".');
end
end
