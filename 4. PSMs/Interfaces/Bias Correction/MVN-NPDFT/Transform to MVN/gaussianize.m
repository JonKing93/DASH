function Xn = gaussianize(X)
%   function Xn = gaussianize(X)
%   Transform each column of data matrix X to normality using the inverse
%   Rosenblatt transform. Tolerates NaNs.
%
% inspired by split.m in normal.m by Van Albada, S.J., Robinson P.A. (2006)
% Transformation of arbitrary distributions to the normal distribution with application to EEG
% test-retest reliability. J Neurosci Meth, doi:10.1016/j.jneumeth.2006.11.004
%
%  Written 26/06/2015 by Julien Emile-Geay (USC)


[n,p] = size(X);
Xn    = NaN(n,p);
for j = 1:p
    % Sort the data in ascending order and retain permutation indices
    Z = X(:,j); nz = ~isnan(Z); N = sum(nz);
    [sorted,index]  = sort(Z(nz));
    % Make 'rank' the rank number of each observation
    [x, rank]       = sort(index);
    % Obtain the cumulative distribution function
    CDF = rank./N - 1/(2*N);
    % Apply the inverse Rosenblatt transformation
    Xn(nz,j) = sqrt(2)*erfinv(2*CDF - 1);  % Xn is now normally distributed
end

end
%test with 30% missing data
% n = 1000;
% X = gamrnd(1,1,[n, 1]); % define highly skewed series
% X(randsample(n,round(n*.30)))= NaN;
% Xn = gaussianize(X);
% scatterhist(X,Xn,'Kernel','on')