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

        % Don't allow empty estimates
        if isempty(Ye)
            emptyEstimatesError;
        end

        % Get sizes, optionally set sizes
        [nRows, nCols, nPages] = size(Ye, 1:3);       
        if isempty(obj.Y) && isempty(obj.R)
            obj.nSite = nRows;
        end    
        if isempty(obj.X)
            obj.nMembers = nCols;
            obj.nPrior = nPages;
        end
    
        % Error check type and size. Require well defined values
        name = 'Observation estimates (Ye)';
        siz = [obj.nSite, obj.nMembers, obj.nPrior];
        dash.assert.blockTypeSize(Ye, 'numeric', siz, name, header);
        dash.assert.defined(Ye, 1, name, header);
        
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

        % Error check and process whichPrior
        obj = obj.processWhich(whichPrior, 'whichPrior', obj.nPrior, ...
                                'priors', timeIsSet, whichIsSet, header);        
    
        % Save and build output
        obj.Ye = Ye;    
        outputs = {obj};
        type = 'set';
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end