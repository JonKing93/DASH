function[A] = doffENSRF(M, D, R, H, obsDetails)
%% Implements data assimilation for a (d)ynamic (off)line model ensemble. 
% Uses an ensemble square root filter to perform updates.
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
%
% ----- Inputs -----
%
% M: A 3D array of time-propagating model ensemble states. Each dim1 x dim2
% matrix is an ensemble of column state vectors at a point in time. Time (dim3)
% extends for the length of the observation averaging period. (N x nEns x tspan)
%
% D: The set of observations (both time-averaged and instantaneous)
% through time. (nObs x t)
%
% R: (nObs x t)
%
% H: Sampling Matrix (nObs x N)
%
% obsDetails
% 

% Do some error checking
errCheck(M, D, R, H, obsDetails)

% Get the number of time steps
nTime = length(sTime);

% For each time step...
for t = 1:nTime
    
    % Get the indices of observations that are available in this time step.
    currObs = ~isnan( D(:,t) );
        
    % If there are obs, then we will update the model states.. If not, then
    % the model prior will be the final state.
    if any(currObs)
        
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
                M(:,:,t) = ensrfUpdate( M(:,:,t), D(currSet,t), R(currSet,t), H(currSet,:) );
                
            % Otherwise, this is a time-average
            % !!!!!!
            % Is there an effect of processing time-averages first or last?
            % What about the order of the time-averages?
            else
                
                % So use a Dirren-Hakim update
                M(:,:,t-nPrev:t) = dhUpdate( M(:,:,t-nPrev:t), D(currSet,t), T(currSet,t), H(currSet,:) );
            end
        end
    end
end
    
    
    
% Does error checking
function[] = errCheck(M, D, R, H, obsDetails)

if ndims(M) ~= 3 
    error('M must be a 3 dimensional array, N x nEns x time');
elseif any(isnan(M(:))) || any(isInf(M(:)))
    error('M should not contain NaN or Inf');
end

if any(isInf(D))
    error('D should not contain Inf');
elseif ~ismatrix(D)
    error('D must be a matrix');
end

if size(D) ~= size(R)
    error('D and R must have the same dimensions');
elseif size(M,3)~=size(D,2)
    error('The time dimensions in M and D are not of equal length.');
elseif size(D,1) > size(M,1)
    error('The number of observations cannot exceed the size of the state vector.')
end

if any(R(:)<=0)
    error('All values in R must be positive.');
end

if ~ismatrix(H) || ~islogical(H)
    error('H must be a logical matrix');
elseif size(H,1) ~= size(D,1)
    error('H and D must have the same number of rows (observations)');
elseif size(H,2) ~= size(M,1)
    error('The number of columns in H must match the number of rows in M (state vector length)');
end

if any( sum(H,2)==0 )
    x = find( sum(H,2)==0,1);
    error( 'Observation %.f is not marked in the sampling matrix H',x);
elseif any( sum(H,2)>1 )
    x = find( sum(H,2)>1,1);
    error('Observation %.f is marked in multiple locations in H',x);
elseif any( sum(H,1)>1 )
    x = find( sum(H,1)>1,1 );
    overlap = find(H(:,x));    
    error('Observations cannot overlap in space. Observations %.f and %.f overlap.',overlap(1),overlap(2));
end    

end




    
    
    




