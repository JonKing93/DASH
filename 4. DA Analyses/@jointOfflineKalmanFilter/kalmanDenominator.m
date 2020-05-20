function[Kdenom] = kalmanDenominator( Ycov, R )
R = diag(R);
Kdenom = Ycov + R;
end