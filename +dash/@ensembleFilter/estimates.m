function[outputs, type] = estimates(obj, header, Ye, whichPrior)
%% 

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:ensembleFilter:estimates";
end

% Return estimates
try
    if ~exist('Ye','var')
        outputs = {obj.Ye, obj.whichPrior};
        type = 'return';
    
    % Delete current matrix. Don't allow second input
    elseif dash.is.strflag(Ye) && strcmpi(Ye, 'delete')
        if exist('whichPrior','var')
            dash.error.tooManyInputs;
        end
    
        % Delete and reset sizes
        obj.Ye = [];
        if isempty(obj.Y) && isempty(obj.R)
            obj.nSite = 0;
        end
        if isempty(obj.X)
            obj.nMembers = 0;
            obj.whichPrior = [];
        end
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior)
            obj.nTime = 0;
        end
    
        % Collect output
        outputs = {obj};
        type = 'delete';
    
    % Set estimates. Get defaults and sizes
    else
        if ~exist('whichPrior','var') || isempty(whichPrior)
            whichPrior = [];
        end
        [nRows, nCols, nPages] = size(Ye, 1:3);
    
        %% Initial error checking
    
        % Optionally set the number of sites
        if isempty(obj.Y) && isempty(obj.R)
            obj.nSite = nRows;
        end
    
        % Optionally set the number of members and priors
        if isempty(obj.X)
            obj.nMembers = nCols;
            obj.nPrior = nPages;
        end
    
        % Error check type and size. Require well defined values
        name = 'Observation estimates (Ye)';
        siz = [obj.nSite, obj.nMembers, obj.nPrior];
        dash.assert.blockTypeSize(Ye, 'numeric', siz, name, header);
        dash.assert.defined(Ye, 1, name, header);
    
    
        %% Error check whichPrior
    
        % Note if whichPrior is already set by the prior
        whichIsSet = false;
        if ~isempty(obj.X) && ~isempty(obj.whichPrior)
            whichIsSet = true;
        end
    
        % Note whether allowed to set nTime
        timeIsSet = true;
        if isempty(obj.Y) && isempty(obj.whichR) && ~whichIsSet
            timeIsSet = false;
        end
    
        % User did not provide whichPrior. If already set by prior, use
        % existing value. Otherwise if evolving, set time when unset. If set,
        % require one prior per time step
        if isempty(whichPrior)
            if whichIsSet
                whichPrior = obj.whichPrior;
            elseif obj.nPrior > 1
                if ~timeIsSet
                    obj.nTime = obj.nPrior;
                end
                if obj.nPrior ~= obj.nTime
                    wrongSizeError;
                end
                whichPrior = (1:obj.nTime)';
            end
    
        % Parse user-provided whichPrior. If already set by the prior, require
        % identical values
        elseif whichIsSet
            if isrow(whichPrior)
                whichPrior = whichPrior';
            end
            if ~isequal(obj.whichPrior, whichPrior)
                differentWhichError;
            end
    
        % Otherwise, user values can set whichPrior. If time is set, require
        % one element per time step. If unset and evolving, set nTime to the
        % number of priors
        else
            nRequired = [];
            if timeIsSet
                nRequired = obj.nTime;
            elseif obj.nPrior > 1
                obj.nTime = numel(whichPrior);
            end
            dash.assert.vectorTypeN(whichPrior, 'numeric', nRequired, 'whichPrior', header);
            linearMax = 'the number of priors';
            dash.assert.indices(whichPrior, obj.nPrior, 'whichPrior', [], linearMax, header);
        end
    
        
        %% Save and update
    
        % Save
        obj.Ye = Ye;
        if obj.nPrior > 1
            obj.whichPrior = whichPrior(:);
        end
    
        % Collect outputs
        outputs = {obj};
        type = 'set';
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end