function[rot] = getRandRot( N )
%% Gets a random rotation matrix for npdft
%
% N: The size of the rotation matrix (NxN)

% Get random, normally distributed values
R = randn( N,N );

% Do a QR decomposition
[Q,R] = qr(R);

% Get the rotation matrix
R = diag(R);
rot = Q * diag( R ./ abs(R) );

end