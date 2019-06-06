function[Amean, Avar] = unappendEnsemble( Amean, Avar, nObs )

% Get the number of state variables
nState = size(Amean,1) - nObs;

% Get the Ye indices in the state vector
ydex = nState + (1:nObs)';

% Remove the Ye from the end of the ensemble
Amean( ydex ) = [];
Avar( ydex, : ) = [];

end