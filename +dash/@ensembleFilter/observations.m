function[outputs, type] = observations(obj, header, Y)
%% dash.ensembleFilter.observations  Process the observations for a filter object
% ----------
%   [outputs, type] = obj.observations(header, ...)
%   Processes options for observations for a filter object. Returns the
%   appropriate outputs collected in a cell, and a string indicating the
%   type of operation performed.
%
%   [obsCell, 'return'] = obj.observations(header)
%   Returns the current observation matrix.
%
%   [objCell, 'set'] = obj.observations(header, Y)
%   Error checks the input observation matrix and overwrites any previously
%   existing observations. Returns the updated filter object.
%
%   [objCell, 'delete'] = obj.observations(header, 'delete')
%   Deletes any current observations and returns the updated filter object.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
%       Y (numeric matrix [nSite x nTime]): Observations for the filter
%
%   Outputs:
%       outputs (cell scalar): Varargout-style outputs
%       type ('return'|'set'|'delete'): Indicates the type of operation
%       obsCell (cell scalar {Y}): The current observations in a cell
%       objCell (cell scalar {obj}): The updated object in a cell
%
% <a href="matlab:dash.doc('dash.ensembleFilter.observations')">Documentation Page</a>

% Setup
try
    if ~exist('header','var') || isempty(header)
        header = "DASH:ensembleFilter:observations";
    end
    dash.assert.scalarObj(obj, header);

    % Return observations matrix
    if ~exist('Y','var')
        outputs = {obj.Y};
        type = 'return';
    
    % Delete current matrix
    elseif dash.is.strflag(Y) && strcmpi(Y, 'delete')
        obj.Y = [];
        if isempty(obj.Ye) && isempty(obj.R)
            obj.nSite = 0;
        end
        if isempty(obj.whichPrior) && isempty(obj.whichR)
            obj.nTime = 0;
        end
        outputs = {obj};
        type = 'delete';
    
    % Set observations matrix. Don't allow empty observations
    else
        if isempty(Y)
            emptyObservationsError;
        end

        % Do initial error checks
        name = 'Observations (Y)';
        dash.assert.matrixTypeSize(Y, ["single","double"], [], name, header);
        dash.assert.defined(Y, 1, name, header);
        
        % Get size of matrix
        [nSite, nTime] = size(Y);

        % Check and set number of sites
        if isempty(obj.Ye) && isempty(obj.R)
            obj.nSite = nSite;
        elseif nSite ~= obj.nSite
            mismatchSitesError(obj, nSite, header);
        end

        % Check and set number of time steps
        if isempty(obj.whichPrior) && isempty(obj.whichR)
            obj.nTime = nTime;
        elseif nTime ~= obj.nTime
            mismatchTimeError(obj, nTime, header);
        end
        
        % Validate observations have R uncertainties
        obj.assertValidR;

        % Set matrix
        obj.Y = Y;
        outputs = {obj};
        type = 'set';
    end
    
% Minimize error stacks
catch ME
    throwAsCaller(ME);
end

end

%% Error messages
function[] = mismatchSitesError(obj, nSite, header)
if ~isempty(obj.Ye)
    type = 'estimates';
else
    type = 'uncertainties';
end
id = sprintf('%s:incorrectNumberOfSites', header);
ME = MException(id, ['You previously specified %s for %.f observation sites, ',...
    'so the observations matrix (Y) must have %.f rows. However, Y has %.f ',...
    'rows instead.'], type, obj.nSite, obj.nSite, nSite);
throwAsCaller(ME);
end
function[] = mismatchTimeError(obj, nTime, header)
if ~isempty(obj.whichR)
    type = 'uncertainties';
elseif ~isempty(obj.Ye)
    type = 'estimates';
else
    type = 'priors';
end
id = sprintf('%s:incorrectNumberOfTimeSteps', header);
ME = MException(id, ['You previously specified %s for %.f time steps, so the ',...
    'observations matrix (Y) must have %.f columns. However, Y has %.f columns instead.'],...
    type, obj.nTime, obj.nTime, nTime);
throwAsCaller(ME);
end
function[] = emptyObservationsError(obj, header)
id = sprintf('%s:emptyObservations', header);
ME = MException(id, 'The observations for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end