function[Knum, Ycov] = localizeCovariance(Knum, Ycov, w, yloc)
Knum = w .* Knum;
Ycov = yloc .* Ycov;
end