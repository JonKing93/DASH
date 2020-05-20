function[Adev] = updateDeviations( Mdev, Ka, Ydev )
% Updates the ensemble deviations
Adev = Mdev - Ka * Ydev;
end