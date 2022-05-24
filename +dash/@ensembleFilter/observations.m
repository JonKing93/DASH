function[outputs, type] = observations(obj, header, Y)
%% dash.ensembleFilter.observations  Provide the observations for a filter
% ----------

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:ensembleFilter:observations";
end

% Return observations matrix
try
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
        dash.assert.matrixTypeSize(Y, 'numeric', [], name, header);
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