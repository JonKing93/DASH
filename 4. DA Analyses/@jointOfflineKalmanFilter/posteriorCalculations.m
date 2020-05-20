function[calcs] = posteriorCalculations( Amean, Adev, Q )
% Amean: nState x nTime
%
% Adev: nState x nEns
%
% Q: nCalcs x 1

% Preallocate the output
nTime = size(Amean);
nCalc = numel(Q);
calcs = NaN( nCalc, nEns, nTime );

% Get the indices for each calculator
for s = 1:numel(Q)
    H = Q{s}.H;
    
    % Perform the calculations in each time step
    for t = 1:nTime
        Acalc = Amean(H,t) + Adev(H,:);
        calcs(:,:,t) = Q{s}.run( Acalc );
    end
end

end