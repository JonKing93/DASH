function[obj] = resetChangedDim( obj, var, d )
% Flip type, delete mean and sequence data. Notify user.

% For each variable
for k = 1:numel(var)
    v = var(k);
    
    % Change the type
    obj.var(v).isState(d) = ~obj.var(v).isState(d);
    
    % Always remove mean
    obj.var(v).takeMean(d) = false;
    obj.var(v).nanflag{d} = [];
    
    % If now a state dimension, completely delete mean and sequence data
    if obj.var(v).isState(d)
        obj.var(v).meanDex{d} = [];
        obj.var(v).seqDex{d} = [];
        obj.var(v).seqMeta{d} = [];
        
    % But if an ensemble, use the defaults
    else
        obj.var(v).meanDex{d} = 0;
        obj.var(v).seqDex{d} = 0;
        obj.var(v).seqMeta{d} = NaN;
    end
end

end
    
