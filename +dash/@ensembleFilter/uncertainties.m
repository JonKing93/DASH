function[outputs, type] = uncertainties(obj, header, R, whichR, type)
%% dash.ensembleFilter.uncertainties  Process the uncertainties for a filter object
% ----------
%   [outputs, type] = <strong>obj.uncertainties</strong>(header, ...)
%   Processes options for uncertainties for a filter. Returns the outputs for
%   the operations collected in a cell. Also returns a string indicate the
%   type of operation performed.
%
%   [uncCell, 'return'] = <strong>obj.uncertainties</strong>(header)
%   Returns the current uncertainties and whichR.
%
%   [objCell, 'set'] = <strong>obj.uncertainties</strong>(header, R)
%   [objCell, 'set'] = <strong>obj.uncertainties</strong>(header, R, whichR)
%   [objCell, 'set'] = <strong>obj.uncertainties</strong>(header, R, whichR, type)
%   Error checks the input uncertainties and whichR and overwrites any
%   previously existing uncertainties. Returns the updated filter object.
%
%   [objCell, 'delete'] = <strong>obj.uncertainties</strong>('delete')
%   Deletes any current uncertainties and returns the updated filter object.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
%       R (numeric matrix [nSite x nR] | numeric array [nSite x nSite x nR]):
%           Uncertainties for the filter
%       whichR (vector, linear indices [nTime]): Indicates which set of
%           uncertainties to use in each time step
%       type (string scalar | scalar logical): Indicates whether the
%           uncertainties are variances or covariances
%           ["v"|"var"|"variance"|false]: Error variances
%           ["c"|"cov"|"covariance"|true]: Error covariances
%       
%   Outputs:
%       outputs (cell scalar): Varargout-style outputs
%       type ('return'|'set'|'delete'): Indicates the type of operation
%       uncCell (cell vector [2] {R, whichR}): The current uncertainties
%           and whichR in a cell
%       objCell (cell scalar {obj}): The updated object in a cell
% 
% <a href="matlab:dash.doc('dash.ensembleFilter.uncertainties')">Documentation Page</a>

% Setup
try
    if ~exist('header','var') || isempty(header)
        header = "DASH:ensembleFilter:uncertainties";
    end
    dash.assert.scalarObj(obj, header);
    
    % Return uncertainties
    if ~exist('R','var')
        outputs = {obj.R, obj.whichR};
        type = 'return';
    
    % Delete current matrix. Don't allow second input
    elseif dash.is.strflag(R) && strcmpi(R, 'delete')
        if exist('whichR','var')
            dash.error.tooManyInputs;
        end
    
        % Delete and reset sizes
        obj.R = [];
        obj.Rtype = NaN;
        obj.whichR = [];
    
        obj.nR = 0;
        if isempty(obj.Y) && isempty(obj.Ye)
            obj.nSite = 0;
        end
        if isempty(obj.Y) && isempty(obj.whichPrior)
            obj.nTime = 0;
        end
    
        % Collect output
        outputs = {obj};
        type = 'delete';
    
    % Set uncertainties. Get defaults
    else
        if ~exist('whichR','var') || isempty(whichVar)
            whichR = [];
        end
    
        % Don't allow empty R
        if isempty(R)
            emptyUncertaintiesError(obj, header);
        end

        % Get sizes
        [nRows, nCols, nPages] = size(R, 1:3);

        % Parse user type
        if exist('type','var')
            switches = {["v","var","variance"], ["c","cov","covariance"]};
            iscovariance = dash.parse.switches(type, switches, 1, 'type',...
                                                    'allowed option', header);
        
        % Otherwise, detect variance vs covariance
        else
            if ~ismatrix(R)
                iscovariance = true;
            elseif nRows ~= nCols
                iscovariance = false;
            elseif obj.nTime>0 && obj.nTime~=nCols
                iscovariance = true;
            else
                ambiguousUncertaintyError(obj, header);
            end
        end
    
        % Parse and set the number of uncertainty sets
        if iscovariance
            nR = nPages;
        else
            nR = nCols;
        end
        obj.nR = nR;
    
        % Optionally set the number of sites
        if isempty(obj.Y) && isempty(obj.Ye)
            obj.nSite = nRows;
        end
    
        % Error check size and type. Require well defined values
        if iscovariance
            name = 'R covariances';
            siz = [obj.nSite, obj.nSite, NaN];
            dash.assert.blockTypeSize(R, ["single","double"], siz, name, header);
        else
            name = 'R variances';
            siz = [obj.nSite, NaN];
            dash.assert.matrixTypeSize(R, 'numeric', siz, name, header);
        end
        dash.assert.defined(R, 2, name, header);
    
        % Note whether allowed to set nTime
        timeIsSet = true;
        if isempty(obj.Y) && isempty(obj.whichPrior)
            timeIsSet = false;
        end
    
        % Error check and process whichR
        obj = obj.processWhich(whichR, 'whichR', nR, name, timeIsSet, false, header);
    
        % Only allow positive variances
        if ~iscovariance
            isnegative = R <= 0;
            if any(isnegative)
                negativeVarianceError(R, isnegative, header);
            end
    
        % Covariances sets must be symmetric matrices with positive diagonals
        else
            dash.assert.covariances(R, 'R covariances', header);
        end
    
        % Save, note type, build output
        obj.R = R;
        obj.Rtype = double(iscovariance);
        outputs = {obj};
        type = 'set';

        % Check that no observations have NaN uncertainties
        obj.assertValidR(header);
    end

% Minimize error stack
catch ME
    if startsWith(ME.identifier, "DASH")
        throwAsCaller(ME);
    else
        rethrow(ME);
    end
end

end

% Error messages
function[] = emptyUncertaintiesError(obj, header)
id = sprintf('%s:emptyUncertainties', header);
ME = MException(id, 'The uncertainties for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = ambiguousUncertaintyError(obj, header)
id = sprintf('%s:ambiguousUncertainty', header);
ME = MException(id, ['Cannot determine whether the input uncertainties for %s',...
    'are variances or covariances. Please use the "type" input (the third ',...
    'input) to indicate whether these are variance or covariances.'], obj.name);
throwAsCaller(ME);
end
function[] = negativeVarianceError(R, isnegative, header)
bad = find(isnegative, 1);
badValue = R(bad);
id = sprintf('%s:negativeVariance', header);
ME = MException(id, ['R variances must be greater than 0, but element %.f ',...
    'of Rvar (%f) is not.'], bad, badValue);
throwAsCaller(ME);
end