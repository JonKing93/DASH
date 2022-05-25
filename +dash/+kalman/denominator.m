function[Kdenom] = denominator(Ydev, Rcov, unbias)

Kdenom = unbias .* (Ydev * Ydev') + Rcov;

end