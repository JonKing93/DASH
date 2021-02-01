function[calcs] = posteriorCalculations( Amean, Adev, Q )
% Amean: nState x nTime
%
% Adev: nState x nEns
%
% Q: nCalcs x 1

% Preallocate the output
nTime = size(Amean,2);
nCalc = numel(Q);
calcs = NaN( nCalc, 2, nTime );

% Get the indices for each calculator
for s = 1:numel(Q)
    H = Q{s}.H;
    calcs(s,:,:) = Q{s}.run( Amean(H,:), Adev(H,:) );
end

end