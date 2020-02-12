function[] = settings( obj, varargin )
% Specifies settings for an Ensemble Square Root Kalman Filter analysis.
%
% obj.ensrfSettings( ..., 'type', type )
% Whether to process updates jointly or in serial. Default is jointly.
%
% obj.ensrfSettings( ..., 'type', 'serial', 'localize', w )
% ensrfSettings( ..., 'type', 'joint', 'localize', {w, yloc} )
% Applies localization weights. See dash.covLocalization for w and yloc.
%
% obj.ensrfSettings( ..., 'inflate', inflate )
% Specify an inflation factor. Default is 1 (no inflation). Note that
% inflation is applied BEFORE generating Ye values.
%
% obj.ensrfSettings( ..., 'type', 'serial', 'append', append )
% Indicate whether to pre-calculate Y estimates, append them to the state
% vector, and update via the Kalman Gain. Default is false.
%
% obj.ensrfSettings( ..., 'type', 'joint', 'meanOnly', meanOnly )
% Specify whether to only update the ensemble mean. (This is typically much
% faster than calculating the ensemble mean and variance.)
%
% obj.settings( ..., 'returnDevs', fullDevs )
% Specify whether to return full ensembles deviations, or just the
% variance. Default is just the variance.
%
% obj.settings( ..., 'percentiles', percentiles )
% Specify which percentiles of the ensemble to return
%
% obj.settings( ..., 'reconstruct', reconstruct )
% Specify which state vector elements to reconstruct. Not recommended. See
% "kalmanFilter.reconstructVars" instead.
% 
% ---- Inputs -----
%
% type: A string indicating the type of updating scheme to use. Default is
%       'serial' - Observations are processed in serial
%       'joint' (Default) - All observations are processed at once.
%
% w: Localization weights between each observation and state vector element.
%    The first output of dash.covLocalization.
%
% yloc: Localization weights betwen observations. The second output of
%       dash.covLocalization.
%
% inflate: An inflation factor. A positive scalar value.
%
% append: A scalar logical indicating whether to use the append method.
%
% meanOnly: A scalar logical indicating whether to only calculate the
%           ensemble mean for joint updating schemes.
%
% fullDevs: A scalar logical indicating whether to return full ensemble
%           deviations. Default is false.
%
% percentiles: A vector of values between 0 and 100, specifying which
%              ensemble percentiles to return.
%
% reconstruct: A logical vector specifying which state vector elements to
%              reconstruct. (nState x 1)

% Parse inputs
[type, weights, inflate, append, meanOnly, fullDevs, percentiles, recon] = parseInputs( varargin, ...
    {'type','localize','inflate','append','meanOnly','returnDevs','percentiles','reconstruct'}, ...
    {obj.type, obj.localize, obj.inflate, obj.append, obj.meanOnly, obj.fullDevs, obj.percentiles, obj.reconstruct}, ...
    {[],[],[],[],[],[],[],[]} );

% Error checking
if ~isstrflag(type)
    error('type must be a string scalar or character row vector.');
elseif ~strcmpi(type,'joint') && ~strcmpi(type,'serial')
    error('Unrecognized type');
elseif ~isnumeric(inflate) || ~isreal(inflate) || ~isscalar(inflate) || inflate<=0
    error('inflate must be a positive scalar value.');
end

if ~isscalar(fullDevs) || ~islogical(fullDevs)
    error('fullDevs must be a scalar logical.');
end

if strcmpi(type,'joint')
    append = false;
elseif ~isscalar(append) || ~islogical(append)
    error('append must be a scalar logical.');
end

if strcmpi(type, 'serial')
    meanOnly = false;
elseif ~isscalar(meanOnly) || ~islogical(meanOnly)
    error('meanOnly must be a scalar logical.');
end
if fullDevs && meanOnly
    error('Cannot compute only the ensemble mean when returning full ensemble deviations.');
end

% Reconstruction indices
if isa(obj.M,'ensemble')
    ensMeta = obj.M.loadMetadata;
    nState = ensMeta.ensSize(1);
else
    nState = size(obj.M,1);
end
reconH = [];
reconstruct = [];
if ~isempty(recon)
    if ~isvector(recon) || ~islogical(recon) || length(recon)~=nState
        error('reconstruct must be a logical vector with nState (%.f) indices.', nState);
    end
    reconH = dash.checkReconH( recon, obj.F );
    if ~reconH && strcmpi(type,'serial') && ~append
        error('When using serial updates without appended Ye, you must reconstruct all state elements used to run the PSMs.');
    end
    reconstruct = recon;
end

% Localization Weights
nRecon = nState;
if ~isempty(obj.reconstruct)
    nRecon = sum( obj.reconstruct );
end
nObs = size(obj.D,1);
if ~isempty(weights)
    if strcmpi(type,'joint') 
        if ( ~iscell(weights) || numel(weights)~=2 )
            error(['Localization weights for joint updates must be provided as the 2-element cell: {w, yloc}\n',...
               'Please see dash.localizationWeights for details.'] );
        elseif ~isnumeric(weights{2}) || ~isreal(weights{2}) || ~ismatrix(weights{2}) || ~isequal(size(weights{2}), [nObs, nObs])
            error('The second element of joint localization weights must be a %.f x %.f numeric matrix', nObs, nObs );
        elseif ~isnumeric(weights{1}) || ~isreal(weights{1}) || ~ismatrix(weights{1}) || ~isequal(size(weights{1}), [nRecon, nObs])
            error('The first element of joint localization weights must be a %.f x %.f numeric matrix.', nRecon, nObs );
        end
    elseif strcmpi(type, 'serial') && ( ~isnumeric(weights) || ~isreal(weights) || ~ismatrix(weights) || ~isequal(size(weights), [nRecon, nObs]) )
        error('serial localization weights must be a %.f x %.f numeric matrix.', nRecon, nObs );
    end
end

% Percentiles
if ~isempty( percentiles )
    if meanOnly
        error('Cannot calculate ensemble percentiles when only updating the ensemble mean.');
    elseif ~isnumeric(percentiles) || ~isvector(percentiles) || any(percentiles<0) || any(percentiles>100) || any(isnan(percentiles)) 
        error('percentiles must be a vector of numeric values between 0 and 100 that do not contain NaN values.');
    end
end

% Save values
obj.type = type;
obj.localize = weights;
obj.inflate = inflate;
obj.append = append;
obj.meanOnly = meanOnly;
obj.fullDevs = fullDevs;
obj.reconstruct = reconstruct;
obj.percentiles = percentiles;
obj.reconH = reconH;

end