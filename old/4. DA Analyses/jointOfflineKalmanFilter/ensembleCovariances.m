function[Knum, Ycov] = ensembleCovariances( Mdev, Ydev )
% Mdev: Prior
%
% Ydev: 
unbias = 1 / (size(Mdev,2)-1);
Knum = unbias .* (Mdev * Ydev');
Ycov = unbias .* (Ydev * Ydev');
end