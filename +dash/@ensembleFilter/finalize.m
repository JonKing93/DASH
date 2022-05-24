function[obj] = finalize(obj, requirePrior, actionName, header)
%% dash.ensembleFilter.finalize  Check that essential data inputs are present for a filter algorithm
% ----------
%   obj = obj.finalize(requirePrior)
%   Requires the filter object to have observations, estimates, and
%   uncertainties. Optionally requires the filter to have a prior. Throws
%   error if these conditions are met. Sets static/empty whichR and
%   whichPrior fields to vectors of 1s. Also sets the "isfinalized"
%   property to a value depending on whether a prior was required.
%
%   obj = obj.finalize(true)
%   Requires a prior. Sets the "isfinalized" property to 2. If the prior is
%   provided via ensemble objects, validates the associated matfiles.
%   Also records the numerical precision of the prior.
%
%   obj = obj.finalize(false)
%   Does not require a prior. Sets the "isfinalized" property to 1.
%
%   obj = obj.finalize(requirePrior, actionName, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       requirePrior (scalar logical): Whether to require a prior
%       actionName (string scalar): A name for the algorithm or calculation
%           requiring a finalized filter.
%       header (string scalar): Header for error IDs
%
%   Outputs:
%       obj (scalar ensembleFilter object): The finalzied filter object
%
% <a href="matlab:dash.doc('dash.ensembleFilter.finalize')">Documentation Page</a>

% Check for essential inputs
try
    if isempty(obj.Y)
        id = sprintf('%s:missingObservations', header);
        error(id, 'You must provide observations before %s.', actionName);
    elseif isempty(obj.Ye)
        id = sprintf('%s:missingEstimates', header);
        error(id, 'You must provide estimates before %s.', actionName);
    elseif isempty(obj.R)
        id = sprintf('%s:missingUncertainties', header);
        error(id, 'You must provide uncertainties before %s.', actionName);
    
    
    % If the prior is required, start by checking its existence
    elseif requirePrior
        if isempty(obj.X)
            id = sprintf('%s:missingPrior', header);
            error(id, 'You must provide a prior before %s.', actionName);
    
        % Numeric array - get precision
        elseif obj.Xtype==0
            obj.precision = class(obj.X);
    
        % Ensemble objects - validate matfile and get precisions
        else
            precisions = strings(obj.nPrior, 1);
            try
                for p = 1:numel(obj.X)
                    [~,~, precisions(p)] = obj.X(p).validateMatfile;
                end
    
            % Informative error if matfile failed
            catch cause
                ensembleFailedError(obj, p, cause, header);
            end
    
            % Get final precision
            obj.precision = gridfile.loadedPrecision(precisions);
        end
    end
    
    % Set static whichR and whichPrior
    if isempty(obj.whichR)
        obj.whichR = ones(obj.nTime, 1);
    end
    if isempty(obj.whichPrior)
        obj.whichPrior = ones(obj.nTime, 1);
    end
    
    % Set finalized property
    if requirePrior
        obj.isfinalized = 2;
    else
        obj.isfinalized = 1;
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end

% Error messages
function[] = ensembleFailedError(obj, p, cause, header)

if numel(obj.X) == 1
    name = 'The ensemble object for the prior';
else
    name = sprintf('The ensemble object for prior %.f', p);
end
label = obj.X(p).label;
if ~strcmp(label, "")
    name = sprintf('%s (%s)', name, label);
end

id = sprintf('%s:ensembleFailed', header);
ME = MException(id, '%s failed.', name);
ME = addCause(ME, cause);
throwAsCaller(ME);

end