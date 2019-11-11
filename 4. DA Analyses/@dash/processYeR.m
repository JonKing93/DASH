function[Ye, R, use] = processYeR( F, Mpsm, R, t, d )
% Estimates Ye and R as a data assimilation is running. Error checks the
% PSM output and determines if it can be used to update.
%
% [Ye, R, use] = dash.processYeR( F, Mpsm, R, t, d )
%
% ----- Inputs -----
%
% F: A scalar PSM object
%
% Mpsm: The ensemble elements needed to run the PSM
%
% R: A row vector of R values. The uncertainty for the observations associated
%    with the PSM site at each processed time step.
%
% t: The current DA time step
%
% d: The proxy order of the current PSM
%
% ----- Outputs -----
%
% Ye: The Ye estimates
%
% R: The merged input and dynamically generated R values
%
% use: Whether or not to use the PSM to update in each processed time step.

% Get some sizes. Preallocate
nEns = size(Mpsm,2);
nTime = size(R,2);
use = false( 1, nTime );

% Find the R values that need dynamic generation
nanR = isnan(R);

getR = false;
if any( nanR )
    getR = true;
end

% Run the PSM, check R and Ye for errors
try
    goodYe = false;
    [Ye, Rpsm] = F.run( Mpsm, t, d );
    
    % Check Ye for errors. If Ye is good, note that any time steps with
    % non-NaN R are ready.
    if ~isequal( size(Ye), [1, nEns] )
        error('Ye is the incorrect size.');
    elseif ~isnumeric(Ye) || any(~isreal(Ye))
        error('Ye must be numeric, and cannot be complex numbers.');
    elseif any(isnan(Ye)) || any(isinf(Ye))
        error('Ye cannot be NaN or Inf.');
    elseif numel(unique(Ye))==1
        error('Ye values are all identical, but the filter requires estimates with non-zero variance.');
    end
    goodYe = true;
    use( ~nanR ) = true;
    
    % Check R for errors if necessary. If good, save and use to update
    % time steps with unspecified R.
    if getR
        if ~isscalar(Rpsm) || ~isnumeric(Rpsm)
            error('R must be a numeric, scalar value.');
        elseif ~isreal(Rpsm) || isnan(Rpsm) || isinf(Rpsm)
            error('R cannot be complex, NaN, or Inf.');
        elseif Rpsm < 0
            error('R cannot be negative.');
        end
        R( nanR ) = Rpsm;
        use( nanR ) = true;
    end
        
    
% If the PSM fails, send the error to the console, but don't crash the DA.
% Create NaN output if necessary.
catch ME
    psmFailureMessage( ME.message, t, d, goodYe );
    if ~goodYe
        Ye = NaN( 1, nEns );
    end
end

end

% Informative error messages.
function[] = psmFailureMessage( message, t, d, goodYe )

if ~isnan(t)
    timestr = sprintf('in time step %.f ', t);
    noupdate = timestr;
    
else
    timestr = '';
    noupdate = '';
    if goodYe
        noupdate = ' in time steps with unspecified R values';
    end
end

fprintf([ 'PSM %.f failed %swith error message: \n', ...
          message, '\n', ...
          '\tDash will not use observations from site %.f to update the analysis%s.\n\n'], ...
          d, timestr, d, noupdate );
end