function[obj] = processWhich(obj, whichArg, field, nIndex, indexType, timeIsSet, whichIsSet, header)
%%

% Unspecified which argument. If already set by another data field, use the
% existing value.
try
    if isempty(whichArg)
        if whichIsSet
            whichArg = obj.(field);
    
        % Otherwise if evolving, set time when unset. If set, require one index
        % per time step
        elseif nIndex > 1
            if ~timeIsSet
                obj.nTime = nIndex;
            end
            if nIndex ~= obj.nTime
                wrongSizeError;
            end
            whichArg = (1:obj.nTime)';
        end
    
    % User-provided which argument. If already set by a different data field,
    % require identical values.
    elseif whichIsSet
        if isrow(whichArg)
            whichArg = whichArg';
        end
        if ~isequal(whichArg, obj.(field))
            differentWhichError;
        end
    
    % Otherwise, user values can set the which argument. If time is set,
    % require one index per time step. If unset and evolving, set nTime to the
    % number of indices
    else
        nRequired = [];
        if timeIsSet
            nRequired = obj.nTime;
        elseif nIndex > 1
            obj.nTime = numel(whichArg);
        end
        dash.assert.vectorTypeN(whichArg, 'numeric', nRequired, field, header);
        linearMax = sprintf('the number of %s', indexType);
        dash.assert.indices(whichArg, nIndex, field, [], linearMax, header);
    end
    
    % Only record the which argument if evolving
    if nIndex > 1
        obj.(field) = whichArg(:);
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end