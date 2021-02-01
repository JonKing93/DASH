function[Ka] = kalmanAdjusted( Knum, Kdenom, R )
R = diag(R);
Ksqrt = sqrtm(Kdenom);
Ka = Knum * (Ksqrt^(-1))' * (Ksqrt + sqrtm(R))^(-1);
end
