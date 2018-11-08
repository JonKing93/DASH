function[Amean, Adev] = updateA(Mmean, K, innov, Mdev, alpha, Ydev)

% Update the state vector mean
Amean = Mmean + K*innov;

% Update the state vector deviations
Adev = Mdev - alpha' .* K * Ydev;

end