function[Mdev] = inflateCovariance( Mdev, inflate )
%% Inflates the covariance of an ensemble.
%
% Mdev = inflateCovariance( Mdev, inflate );
Mdev = Mdev .* sqrt(inflate);
end