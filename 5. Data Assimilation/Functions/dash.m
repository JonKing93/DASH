function[varargout] = dash( M, D, R, F, varargin )
%% Implements data assimilation using dynamic PSMs or the tardif method.
%
% [Amean, Avar, Ye] = dash( M, D, R, F )
% Runs a data assimilation using dynamic forward models and a joint update
% scheme. Returns the updated ensemble mean, updated ensemble variance, and
% forward model estimates. 
% 
% dash( ..., 'serial', true )
% Runs a data assimilation using serial updates.
%
% dash( ..., 'serial', true, 'append', true )
% Run serial updates using the appended Ye method. Ye values are
% calculated for the initial model prior, appended to the state vector, and
% updated through the Kalman Gain. Returns the Ye estimates from the
% initial estimate (Yi), used for updating (Yu), and final estimate (Yf).
%
% dash( ... , 'inflate', inflate )
% Specifies an inflation factor. The covariance of the model ensemble will
% be multiplied by the inflation factor.
%
% dash( ..., 'localize', {w, yloc} )
% Specifies a covariance localization to use in data assimilation for a 
% joint update scheme. See the covLocalization.m function.
%
% dash( ..., 'serial', true, 'localize', w )
% Specifies covariance localization weights to use for data assimilation
% with a serial update scheme. See the covLocalization.m function.
%
% [outArg] = dash( ..., 'output', {outputs} )
% Specify required outputs. If certain outputs (such as Avar) are not
% calculated, runtime can greatly increase.
%
% ----- Inputs -----
%
% M: The model ensemble. (nState x nEns)
%
% D: The observations. (nObs x nTime)
%
% R: Observation uncertainty of each proxy measurement. Values for NaN
%    elements are generated dynamically by the PSMs. (nObs x nTime )
%
% F: A cell vector of PSM objects. {nObs x 1}
%
% inflate: A scalar inflation factor. 
%
% w: Model-estimate covariance localization weights. Applied to the Kalman
%    numerator. (nState x nObs)
%
% yloc: Estimate-estimate covariance localization weights. Applied to the
%       Kalman denominator. (nObs x nObs)
%
% outputs: Flags for possible outputs
%     'Amean': Updated ensemble mean
%     'Avar': Updated ensemble variance
%     'Ye': The ensemble of model estimates at each time step
%
%     'Yi': The initial model estimates generated for the appended Ye method
%     'Yu': The model estimates used for each update step for the appended Ye method.
%     'Yf': The final model estimates from the appended Ye method. This is
%           the same value returned as 'Ye' for the appended method.
%
% ----- Outputs -----
%
% Amean: Update analysis mean. (nState x nTime).
%
% Avar: Update analysis variance (nState x nTime).
%
% Ye: Model estimates.
%       serial DA: (nObs x nEns x nTime)
%       joint DA: (nObs x nEns)
% 
% Yi: The initial model estimate for the appended Ye method. (nObs x nEns)
%
% Yu: The model estimate used to update each time step for the appended Ye
%     method. (nObs x nEns x nTime)
%
% Yf: The final model estimate for each time step. (nObs x nEns x nTime)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

%% Setup 

% Parse inputs
[serial, append, inflate, localize, output] = parseInputs( varargin, {'serial','append','inflate','localize','output'}, ...
                                                           {false, false, 1, [], []}, {[],[],[],[],[]} );
                                        
% Error check. Get R and w if unspecified.
[R, w] = setup( M, D, R, F, serial, append, inflate, localize, output );

% Apply the inflation factor
M = inflateEnsemble( inflate, M );

% Setup for the appended Ye method
if append
    [M, F] = appendSetup( M, F );
end

% Run a serial or jointly updating data assimilation
if serial
    [A, Ye] = serialDA( M, D, R, F, w );
else
    [A, Ye] =  jointENSRF( M, D, R, F, w, yloc );
end

% Finish for the appened Ye method
if append
    [Amean, Avar] = 
    
    % Unappend
    Yf = A(nState+1:end,:,:);
    A = A(1:nState,:,:);
    
    % Get the Y output cell
    Ye = {Yi, Ye, Yf};
end


% Get outputs

end

function[R, w] = setup( M, D, R, F, inflate, w, append, serial )
    
% Get the number of state elements
nState = size(M,1);
[nObs, nTime] = size(D,1);
    
% Check that observations are a matrix of real, numeric values
if ~ismatrix(D) || ~isreal(D) || ~isnumeric(D) || any(isinf(D(:)))
    error('D must be a matrix of real, numeric, finite values.');
end

% Convert R to a nObs x nTime matrix
if isempty(R)
    R = NaN(nObs, nTime);
elseif isscalar(R)
    R = repmat(R, [nObs, nTime]);
elseif iscolumn(R)
    R = repmat( R, nTime );
end

% Check R is real, numeric, finite, and non-negative
if ~ismatrix(R) || ~isreal(R) || ~isnumeric(R) || any(isinf(R(:)))
    error('R must be a matrix of real, numeric, finite values.');
elseif any( R(:) < 0 )
    error('R cannot contain negative values.');
elseif (size(R,1)~=size(D,1) || size(R,2)~=size(D,2))
    error('The number of rows and columns in R do not match the number in D.');
end

% Check F
if ~isvector( F )
    error('F must be a vector of PSM objects.');
elseif numel(F) ~= size(D,1)
    error('The number of PSMs does not match the number of observations.');
end
for k = 1:nObs
    
    % Check that each element is a PSM
    if ~isa( F{k}, 'PSM' )
        error('Element %.f of F is not a PSM', k);
    end
    
    % Have the PSM do an internal error check
    F{k}.reviewPSM;
end

% Inflation factor
if ~isscalar(inflate) || inflate<=0 || isinf(inflate) || isnan(inflate) || ~isnumeric(inflate)
    error('The inflation factor must be a scalar greater than 0. It must be real, numeric, finite and not NaN.');
end

% Covariance localization
if isempty(w)
    w = ones(nState, nObs);
elseif ~ismatrix(w) || ~isnumeric(w) || ~isreal(w)
    error('w must be a real, numeric matrix.');
elseif size(w,1) ~= nState
    error('The number of rows in w does not match the number of state elements (i.e. rows of M).');
elseif size(w,2)~=size(D,1)
    error('The number of columns in w must match the number of rows in D.');
end

% Append and serial
if ~isscalar(append) || ~islogical(append)
    error('append must be a scalar logical.');
elseif ~isscalar(serial) || ~islogical(serial)
    error('serial must be a scalar logical.');
end

end