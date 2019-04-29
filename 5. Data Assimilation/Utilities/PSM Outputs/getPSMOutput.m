function[Ye, R, update] = getPSMOutput( F, Mpsm, R, t, d )
%
% ----- Inputs -----
%
% R: Note that R is a VECTOR of R values. This enables calculation of R for
% joint updates.

% Get some sizes
nEns = size(Mpsm,2);
nTime = size(R,2);

% Get an array to track when the PSM should be used to update
update = false( 1, nTime );

% Check which R values are NaN
nanR = isnan(R);

% If there are NaN R values, the PSM should estimate R
getR = false;
if any( nanR )
    getR = true;
end

% Run the PSM
try
    
    % If needed, estimate R
    if getR
        [Ye, Rpsm] = F.runPSM( Mpsm, t, d );
        
        % If R is valid, use for the NaN R values
        if isValidR( Rpsm )
            R( nanR ) = Rpsm;
            
        % If R is not valid, notify the user
        else
            invalidRMessage( t, d );
        end
        
    % Otherwise don't estimate R.
    else
        Ye = F.runPSM( Mpsm, t, d );
    end
    
    % Check that the Ye values are valid, throw a useful error message if not
    checkYeValues( Ye, nEns, d );
    
    % If the Ye values were valid, update at all the time steps where R is
    % also valid
    update( ~isnan(R) ) = true;
    
    
% If the PSM did not run successfully
catch ME
    
    % Notify the user
    psmFailureMessage(ME.message, t, d);
    
    % Create NaN Ye output
    Ye = NaN(1, nEns);
    
    % Revert R to its original state
    R( nanR ) = NaN;
    
    % Do not use the PSM to update the analysis.
    update(:) = false;
end

end


function[] = invalidRMessage( t, d )

timestr = '';
if ~isnan(t)
    timestr = sprintf(' in time step %0.f', t);
end

fprintf(['PSM %0.f failed to generate R%s.\n', ...
         'Dash will not use observation %0.f to update the analysis%s.\n\n'], ...
         d, timestr, d, timestr );
end

function[] = psmFailureMessage( str, t, d )

timestr = '';
if ~isnan(t)
    timestr = sprintf('in time step %0.f ', t);
end

fprintf(['PSM %0.f failed to run %swith the error message: \n', ...
        str, '\n', ...
        '\tDash will not use observation %0.f to update the analysis %s\n\n'], ...
        d, timestr, d, timestr );
end

function[tf] = isValidR( R )

% Intialize the boolean
tf = true;

% Return false if invalid
if ~isscalar(R) || isnan(R) || isinf(R) || ~isreal(R) || R<0
    tf = false;
end

end