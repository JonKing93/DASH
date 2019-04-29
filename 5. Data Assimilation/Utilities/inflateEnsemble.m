function[M] = inflateEnsemble( inflate, M )

% Don't both inflating if the inflation factor is 1. 
if inflate ~= 1
    [Mmean, Mdev] = decomposeEnsemble( M );
    Mdev = sqrt(inflate) .* Mdev;
    M = Mmean + Mdev;
end

end