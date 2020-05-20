function[Knum, Ycov] = ensrfCovariance( Mdev, Ydev, w, yloc )
unbias = 1 / (size(Mdev,2)-1);
Knum = unbias .* w .* (Mdev * Ydev');
Ycov = unbias .* yloc .* (Ydev * Ydev)';
end