function[outputs, type] = estimates(obj, header, Ye, whichPrior)
%% dash.ensembleFilter.estimates  Process the estimates for a filter object
% ----------
%   [outputs, type] = obj.estimates(header, ...)
%   Processes options for estimates for a filter. Returns the outputs for
%   the operations collected in a cell. Also returns a string indicate the
%   type of operation performed.
%
%   [estCell, 'return'] = obj.estimates(header)
%   Returns the current estimates and whichPrior.
%
%   [objCell, 'set'] = obj.estimates(header, Ye)
%   [objCell, 'set'] = obj.estimates(header, Ye, whichPrior)
%   Error checks the input estimates and whichPrior and overwrites any
%   previously existing estimates. Returns the updated filter object.
%
%   [objCell, 'delete'] = obj.estimates('delete')
%   Deletes any current estimates and returns the updated filter object.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
%       Ye (numeric array [nSite x nMembers x nPrior]): Estimates for the filter
%       whichPrior (vector, linear indices [nTime]): Indicates which prior
%           (set of estimates) to use in each time step.
%       
%   Outputs:
%       outputs (cell scalar): Varargout-style outputs
%       type ('return'|'set'|'delete'): Indicates the type of operation
%       estCell (cell vector [2] {Y, whichPrior}): The current estimates and
%           whichPrior in a cell
%       objCell (cell scalar {obj}): The updated object in a cell
% 
% <a href="matlab:dash.doc('dash.ensembleFilter.estimates')">Documentation Page</a>

% Setup
try
    if ~exist('header','var') || isempty(header)
        header = "DASH:ensembleFilter:estimates";
    end
    dash.assert.scalarObj(obj, header);

    % Return estimates
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
            obj.nPrior = 0;
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
        dash.assert.blockTypeSize(Ye, ["single","double"], siz, name, header);
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

% Error messages
function[] = emptyEstimatesError(obj, header)
id = sprintf('%s:emptyEstimates', header);
ME = MException(id, 'The estimates for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end