function[Knum, Ycov] = blendCovariance( Knum, Ycov, Knum_clim, Ycov_clim, b )
Knum = b(1).*Knum + b(2).*Knum_clim;
Ycov = b(1).*Ycov + b(2).*Ycov_clim;
end