function[] = ensrfDriver
%% Implements data assimilation for a dynamic offline model ensemble. Uses
% an ensemble square root filter to perform updates.
%
% Handles seasonally dependent observations.
%
% Handles time-averaged obs.
%
% Handles time-averaged obs that overlap instantaneous obs.
%
% Handle changing numbers of obs
%
% Handles time-averages that occur within a larger time-average
%
% DOES NOT handle overlapping time averages. (Explicitly checks to make
% sure these do not occur) (Still need to code this)
%
% DOES NOT handle overlapping sites (but eventually should...)
%



% M: Time-propagating (N x nEns x t)
%
% D: (nObs x t) If there are not observations at a site during a particular
% time step, it should be marked with NaN.
%
% R: (nObs x t)
%
% H: Sampling Matrix (nObs x N)
%
% sdex: A logical matrix that indexes the season of each observation. Each
% column is one season. Time averages should have markers in multiple
% seasons.
%
% sTime: A vector containing the season of each time step
%
% 


% !!!!!
% We should implement error checks here.




% Get the number of time steps
nTime = length(sTime);

% For each time step...
for t = 1:nTime
    
    % Get the indices of observations that are available in this time step.
    currObs = ~isnan( D(:,t) );
    
    % If there aren't any obs...
    if ~any(currObs)
        
        % The update is just the model prior.
        A(:,:,t) = M(:,:,t);
        
    % But if there are obs...
    else
        
        % Get all the sets of current observations. This may include
        % instantaneous observations and time-averaged observations of
        % different lengths. Note that time-averages all end on this time step.
        obsSets = unique( obsDetails(currObs,:), 'rows');
        nSets = size(obsSets,1);

        % For each set of observations...
        for s = 1:nSets
            
            % Get the indices of current observations in the set
            currSet = currObs & (obsDetails(:,1)==obsSets(s));
            
            % Get the number of previous states recorded by the observation
            nPrev = obSets(s,2);
            
            % If no previous states are used...
            if nPrev == 0
                
                % Then this is the set of instantaneous obs. Get the
                % updated state.
                A(:,:,t) = ensrfUpdate( M(:,:,t), D(currSet,t), R(currSet,t), H(currSet,:) );
                
            % Otherwise, this is a time-average
            % !!!!!!
            % Is there an effect of processing time-averages first or last?
            % What about the order of the time-averages?
            else
                
                % So use a Dirren-Hakim update
                A(:,:,t-nPrev:t) = dhUpdate( M(:,:,t-nPrev:t), D(currSet,t), T(currSet,t), H(currSet,:) );
            end
        end
    end
end
    
    
    
    
    
    
    
    




