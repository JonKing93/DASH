function[obj] = parseWhichPrior(obj, whichPrior, header)

% whichPrior can be empty or a vector
if ~isempty(whichPrior)
    dash.assert.vectorTypeN(whichPrior, 'numeric', [], 'whichPrior', header);
    whichPrior = whichPrior(:);
end

% Static whichPrior
if obj.nPrior == 1
    if ~isempty(whichPrior)
        if ~all(whichPrior==1)
            staticWhichNotOnesError;
        elseif obj.nTime>0 && numel(whichPrior)~=obj.nTime
            staticWhichWrongLengthError;
        end
    end

% Evolving whichPrior. If already set, require identical when not empty
else
    if ~isempty(obj.whichPrior)
        if ~isempty(whichPrior) && ~isequal(whichPrior, obj.whichPrior)
            differentWhichError;
        end

    % If not already set, get default when empty
    else
        checkIndices = true;
        if isempty(whichPrior)
            whichPrior = (1:obj.nPrior)';
            checkIndices = false;
        end

        % Check length matches time, set time to match length if unset
        nEls = numel(whichPrior);
        if obj.nTime>0 && nEls~=obj.nTime
            mismatchTimeError;
        elseif obj.nTime==0
            obj.nTime = nEls;
        end

        % Check indices and set whichPrior
        if checkIndices
            logicalReq = 'have one element per prior';
            linearMax = 'the number of priors';
            whichPrior = dash.assert.indices(whichPrior, nPrior, ...
                                'whichPrior', logicalReq, linearMax, header);
        end
        obj.whichPrior = whichPrior;
    end
end

end