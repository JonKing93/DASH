function[M] = load( obj )
%% Returns an ensemble as output
%
% M = obj.load
%
% ----- Outputs -----
%
% M: The ensemble.

% Check that the .ens file has not been altered. Get the ensemble
m = checkEnsFile( obj.file );
M = m.M;
end