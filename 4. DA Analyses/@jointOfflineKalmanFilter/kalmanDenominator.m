function[] = kalmanDenominator( Ydev, R, yloc )
unbias = 1 / (size(Ydev,2)-1);
R = diag(R);
Kdenom = unbias .* yloc .* (Ydev * Ydev') + R;
end