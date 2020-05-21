function[] = kalmanAdjusted( Knum, Kdenom, R )
R = diag(R);
Ka = Knum * (sqrtm(Kdenom)^(-1))' * (sqrtm(Kdenom) + sqrtm(R))^(-1);
end
