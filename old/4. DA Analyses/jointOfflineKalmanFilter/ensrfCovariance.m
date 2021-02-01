function[Knum, Ycov] = ensrfCovariance( Mdev, Ydev, inflate, w, yloc, Knum_clim, Ycov_clim, b )

% Inflate
if ~isempty(inflate)
    Mdev = inflateCovariance( Mdev, inflate );
end

% Determine covariances
[Knum, Ycov] = ensembleCovariances( Mdev, Ydev );

% Localize
if ~isempty(w)
    [Knum, Ycov] = localizeCovariance( Knum, Ycov, w, yloc );
end

% Blend
if ~isempty( Knum_clim )
    [Knum, Ycov] = blendCovariance( Knum, Ycov, Knum_clim, Ycov_clim, b );
end

end
