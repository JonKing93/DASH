function[output] = run( obj )
% Runs a particle filter for a specific particleFilter object.
%
% output = obj.run
%
% ----- Outputs -----
%
% output: A structure with the following fields
%
%   settings - Settings used to run the analysis
%
%   A - The updated ensemble mean (nState x nTime)
%
%   sse - The sum of squared errors for each particle (nEns x nTime)
%
%   weights - The weights used to compute the updated ensemble mean

% Switch to the alternative algorithm if using a large ensemble
if obj.big
    output = dash.bigpf( obj.M, obj.D, obj.R, obj.F, obj.N, obj.batchSize );
    
% Otherwise, load the ensemble if necessary, then run the normal algorithm
else
    M = obj.M;
    if isa( obj.M, 'ensemble')
        M = obj.M.load;
    end
    output = dash.pf( M, obj.D, obj.R, obj.F, obj.N ); 
end

end